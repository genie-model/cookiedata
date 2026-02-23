function [] = fun_make_ensemble(STR_TEMPLATE,STR_PARAMS)
%
%   ***********************************************************************
%   *** fun_make_ensemble *************************************************
%   ***********************************************************************
%
%   fun_make_ensemble
%   creates all the user-config files needed for a 3D parameter ensemble
%   also creates an ensemble description file: '*.KEY.txt'
%   The resulting ensemble can be submitted by modifying the BASH script:
%   sub_ens.muffin.sh
%
%   STR_TEMPLATE == full filename of the 'template' (default) user-config
%                   NOTE: this filename can be anything you want and
%                         will not form part of the ensemble name
%   STR_PARAMS   == full filename of the parameter configuration file
%                   NOTE: this filename can be anything you want, but:
%                         (i)  it will form the ensemble name
%                         (ii) if it ends in '.dat' or '.txt', the
%                              extension will be stripped out of the
%                              saved ensemble member filenames
%
%  fun_make_ensemble must be run form the same directory that contains:
%  (a) the 'template' (default) user-config file
%  (b) the file containing the parameter configuration
%
%   The format of the file containing the parameter configuration is
%   (by column number):
%   (1) parameter change number (ID) [integer]
%   (2) parameter name [string]
%   (3) default parameter value
%   (4-n) any number of parameter modifiers [real]
%   NOTE: where more than 1 parameter shares the same ID 
%         (and hence are modified together in the same ensemble member)
%         adding the (duplicate) vector is not necessary
% 
%   EXAMPLE 1
%
%   The parameter configuration file contents:
%
%   1 go_0 1.0E-3 0.0 10.0 100.0
%   2 ea_0 1.0E6  1.0 0.8 0.6 0.4 0.2 0.0
%
%   would create a 1 x 6 x 3 ensemble,
%   modifying param setting go_0=1.0E-3 by vector [0.0 10.0 100.0]
%   and parameter setting ea_0=1.0E6 by vector [1.0 0.8 0.6 0.4 0.2 0.0]
%
%   EXAMPLE 2
%
%   The parameter configuration file contents:
%
%   1 go_0 1.0E-3 0.0 10.0 100.0
%   1 go_9 1.0E-9 1.0 2.0 3.0
%   2 ea_0 1.0E6  1.0 0.8 0.6 0.4 0.2 0.0
%
%   would create a 1 x 6 x 3 ensemble as example #1, 
%   but also modifying go_9 at the same time as go_0
%
%   EXAMPLE 3
%
%   The parameter configuration file contents:
%
%   1 go_0 1.0E-3 0.0 10.0 100.0
%
%   creates a 1 x 1 x 6 ensemble in which only one parameter varies.
%
%   ***********************************************************************
%   *** HISTORY ***********************************************************
%   ***********************************************************************
%
%   26/01/18: adapted from fun_make_ensemble_2d to 3d
%
%   ***********************************************************************

% *********************************************************************** %
% *** INITIALIZE PARAMETERS & VARIABLES ********************************* %
% *********************************************************************** %
%
% *** initialize ******************************************************** %
%
% set template user-config filename
str_template = STR_TEMPLATE;
% set parameter definition filename string
str_file = STR_PARAMS;
% set date
str_date = [datestr(date,11), datestr(date,5), datestr(date,7)];
%
% *** load ensemble parameter file ************************************** %
%
% get number of lines in config file
loc_params = fileread(str_file);
loc_params = regexp(loc_params, '\n', 'split');
l_lines = length(loc_params);
% filter comment lines
for l=[l_lines:-1:1]
    loc_str = char(loc_params(l));
    if (strcmp('%',loc_str(1)))
        loc_params(l) = [];
        l_lines = l_lines - 1;
    end
end
% parse strings
for l=[1:l_lines]
    loc_str = char(loc_params(l));
    loc_c = textscan(loc_str,'%s');
    loc_c = loc_c{1};
    n_var = length(loc_c);
    % create structure data
    s(l).id = str2num(cell2mat(loc_c(1)));
    s(l).paramname = char(loc_c{2});
    s(l).defaultvalue = str2double(cell2mat(loc_c(3)));
    loc_v = [];
    for m=[4:n_var]
        loc_v = [loc_v str2double(cell2mat(loc_c(m)))];
    end
    s(l).vector = loc_v;
    if ((l > 1) && (s(l).id == s(l-1).id))
        s(l).unique = false;
    else
        s(l).unique = true;
    end
end
% determine total number of parameters
par_pmax = length([s(:).id]);
% determine number of dimensions used
par_dmax = max([s(:).id]);
% determine number of parameter modifications to make (for each parameter)
% NOTE: seed dimensions vector first
par_vmax = [1 1 1];
for d=1:par_dmax
    loc_v = find([s(:).id] == d);
    loc_p = loc_v(1);
    par_vmax(d) = length(s(loc_p).vector);
end
%
% *** create ensemble parameter filename string ************************* %
%
str_name = str_file;
if (strcmp(str_file(end-3:end),'.dat')), str_name = str_file(1:end-4); end
if (strcmp(str_file(end-3:end),'.txt')), str_name = str_file(1:end-4); end
%
% *********************************************************************** %

% *********************************************************************** %
% *** CREATE ENSEMBLE CONFIG FILES ************************************** %
% *********************************************************************** %
%
% loop through all unique parameter modifications
for o=1:par_vmax(3)
    for n=1:par_vmax(2)
        for m=1:par_vmax(1)
            % create a vector of where we are in the nested loop
            % NOTE: parammeter #1 == m and hence index 1
            loc_vn = [m n o];
            % copy template
            str_templatefilein  = [str_template];
            str_templatefileout = [str_date '.' str_name '.' hex2str(o) hex2str(n) hex2str(m)];
            copyfile(str_templatefilein,str_templatefileout,'f');
            % open sesame! (file pipe of ensemble member user-config)
            fid = fopen(str_templatefileout, 'a+');
            % write parameter file header info
            loc_str = '# ';
            fprintf(fid, '%s\n', loc_str);
            loc_str = '# --- generated by MATLAB with love :) --------------------------------';
            fprintf(fid, '%s\n', loc_str);
            loc_str = '# ';
            fprintf(fid, '%s\n', loc_str);
            % write parameters -- loop through all parameters
            for p=1:par_pmax
                % add comment line
                loc_str = ['# parameter: ' s(p).paramname ' -- default value (' num2str(s(p).defaultvalue) ') modified by factor: ' num2str(s(p).vector(loc_vn(s(p).id)))];
                fprintf(fid, '%s\n', loc_str);
                % add parameter line
                loc_str = [s(p).paramname '=' num2str(s(p).vector(loc_vn(s(p).id))*s(p).defaultvalue)];
                fprintf(fid, '%s\n', loc_str);
            end
            % add parameter file end marker
            loc_str = '# ';
            fprintf(fid, '%s\n', loc_str);
            % close file pipe of ensemble member user-config
            fclose(fid);
        end
    end
end
%
% *********************************************************************** %

% *********************************************************************** %
% *** SUMMARY SAVE ****************************************************** %
% *********************************************************************** %
%
% *** write ensemble parameter info file ******************************** %
%
str_infofile = [str_date '.' str_name];
fid0 = fopen(str_infofile, 'w');
for p=1:par_pmax
    loc_str = [s(p).paramname ' ' num2str(s(p).defaultvalue*s(p).vector)];
    fprintf(fid0, '%s\n', loc_str);    
end
fclose(fid0);
%
% *** write ensemble parameter key file ********************************* %
%
str_keyfile = [str_date '.' str_name '.KEY.txt'];
fid0 = fopen(str_keyfile, 'w');
loc_str = [' ***********************************************************'];
fprintf(fid0, '%s\n', loc_str);
loc_str = ['     ensemble name                    : ' str_date '.' str_name];
fprintf(fid0, '%s\n', loc_str);
loc_str = ['     template user-config filename    : ' str_template];
fprintf(fid0, '%s\n', loc_str);
loc_str = ['     parameter specification filename : ' str_file];
fprintf(fid0, '%s\n', loc_str);
for p=1:par_pmax
    if (s(p).unique)
        loc_str = [' -----------------------------------------------------------'];
        fprintf(fid0, '%s\n', loc_str);
        loc_str = ['     ensemble axis #' num2str(s(p).id)];
        fprintf(fid0, '%s\n', loc_str);
    end
    loc_str = ['     parameter                        : ' s(p).paramname];
    fprintf(fid0, '%s\n', loc_str);    
    loc_str = ['     default value                    : ' num2str(s(p).defaultvalue)];
    fprintf(fid0, '%s\n', loc_str);    
    loc_str = ['     parameter modifiers              : ' num2str(s(p).vector)];
    fprintf(fid0, '%s\n', loc_str);    
end
loc_str = [' ***********************************************************'];
fprintf(fid0, '%s\n', loc_str);
loc_str = ['     individual ensemble members (z,y,x):'];
fprintf(fid0, '%s\n', loc_str);
for o=1:par_vmax(3)
    for n=1:par_vmax(2)
        for m=1:par_vmax(1)
            % create a vector of where we are in the nested loop
            % NOTE: parammeter #1 == m and hence index 1
            loc_vn = [m n o];
            % add ensemble key file info
            loc_str = ['member #' hex2str(o) hex2str(n) hex2str(m) ':'];
            fprintf(fid0, '%s\n', loc_str);
            for p=1:par_pmax
                % add comment line to ensemble key file
                loc_str = ['           ' s(p).paramname '=' num2str(s(p).vector(loc_vn(s(p).id))*s(p).defaultvalue)];
                fprintf(fid0, '%s\n', loc_str);
            end
        end
    end
end
% add terminal comment line to ensemble key file
loc_str = [' ***********************************************************'];
fprintf(fid0, '%s\n', loc_str);
% close file pipe of ensemble key file
fprintf(fid0, '\n', loc_str);
fclose(fid0);
%
% *********************************************************************** %

% *********************************************************************** %
% *** END *************************************************************** %
% *********************************************************************** %
%
%
% *********************************************************************** %
