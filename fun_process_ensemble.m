function [] = fun_process_ensemble(DUM_S)
%
%   ***********************************************************************
%   *** fun_process_ensemble **********************************************
%   ***********************************************************************
%
%   DUM_ENSEMBLE == ensemble name 
%   (omitting the numerical code of individual ensemble members)
%   e.g. for the 2x3 (6 member) ensemble:
%   run00,run01,run02,run10,run11,run12
%   >> fun_process_ensemble_2d('run',9999.5,'myensemble')
%   DUM_YEAR == year of model data to extract
%   DUM_NAME == name to assign to the output files
%               (which could be different to and more meaningful than
%                e.g. DUM_ENSEMBLE)
%
%   NOTE: you must add a path ('addpath') the location of plot_2dgridded2
%         (in muffindata folder) if it is not already present in the same
%         directory in whcih you are running fun_process_ensemble_2d
%   NOTE: if you process time-slice (netCDF) data of the ensemble analysis,
%         you must add a path to the location of the muffinplot folder
%
%   NOTE: You need to EDIT this file to make it work ...
%         and ADD code inbetween the indicated marker lines:
% \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
% /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
%
%   For the selection of variables to extract and plot/analyse, 
%   some commond examples are given below
%   NOTE: these must be (uncommented and) copy-pasted in the appropriate 
%         section of the code
% 
%   EXAMPLE time-series:
%
%   % atmopsheric pCO2
%   m = m+1;
%   data(m).dataname = 'atm_pCO2';
%   data(m).datacol  = 3;
%   data(m).scale    = 1.0E6;
%   data(m).dataunit = 'pCO_2 (ppm)';
%   data(m).minmax   = [180 280];
%   % atmopsheric pCO2 d13C
%   m = m+1;
%   data(m).dataname = 'atm_pCO2_13C';
%   data(m).datacol  = 3;
%   data(m).scale    = 1.0;
%   data(m).dataunit = 'pCO_2 \delta^{13}C (o/oo)';
%   data(m).minmax   = [-7.0 -6.0];
%   % global POC export
%   m = m+1;
%   data(m).dataname = 'fexport_POC';
%   data(m).datacol  = 2;
%   data(m).scale    = 12.0E-15;
%   data(m).dataunit = 'POC export (PgC yr^{-1})';
%   data(m).minmax   = [6.0 12.0];
%   % global mean [O2]
%   m = m+1;
%   data(m).dataname = 'ocn_O2';
%   data(m).datacol  = 3;
%   data(m).scale    = 1.0E+6;
%   data(m).dataunit = '[O_2] (\mumol kg^{-1})';
%   data(m).minmax   = [120 180];
%   % AMOC
%   m = m+1;
%   data(m).dataname = 'AMOC strength';
%   data(m).datacol  = 0;
%   data(m).scale    = 1.0;
%   data(m).dataunit = 'AMOC (Sv)';
%   data(m).minmax   = [0 20];
%   % model skill score of global ocean salinty
%   m = m+1;
%   data(m).dataname = 'ocn_sal';
%   data(m).datacol  = 0;
%   data(m).scale    = 1.0;
%   data(m).dataunit = 'MSS (n/a)';
%   data(m).minmax   = [0.45 0.55];
%   % model skill score of global ocean PO4
%   m = m+1;
%   data(m).dataname = 'ocn_PO4';
%   data(m).datacol  = 0;
%   data(m).scale    = 1.0;
%   data(m).dataunit = 'MSS (n/a)';
%   data(m).minmax   = [0.6 0.7];
%   % model skill score of global ocean O2
%   m = m+1;
%   data(m).dataname = 'ocn_O2';
%   data(m).datacol  = 0;
%   data(m).scale    = 1.0;
%   data(m).dataunit = 'MSS (n/a)';
%   data(m).minmax   = [0.4 0.6];
% 
%   EXAMPLE time-slices:
%
%   % extract AMOC
%   n = n + 1;
%   str = plot_fields_biogem_3d_i(loc_str_exp,'','ocn_temp','',loc_year,-1,0,['mask_worlg4_Atlantic.dat'],1.0,0.0,30.0,30,'','plot_fields_settings_OPSI_ATL',[loc_str_exp '.MOC.ATL']);
%   loc_data = str.moc_max;
%   data(n).array(y,x) = data(n).scale*loc_data;
%   % extract and compare ocean temperature to observations
%   n = n + 1;
%   str = plot_fields_biogem_3d_k(loc_str_exp,'worlg4.WOA13_Temperature_degC_worlg4.151207.nc','ocn_temp','T',loc_year,1,0,'',1.0,-4.0,4.0,40,'','plot_fields_SETTINGS_ANOM',[loc_str_exp '.temp.AMON']);
%   loc_data = str.statm_m;
%   data(n).array(y,x) = data(n).scale*loc_data;
%   % extract and compare ocean salinity to observations
%   n = n + 1;
%   str = plot_fields_biogem_3d_k(loc_str_exp,'worlg4.WOA13_Salinity_worlg4.151207.nc','ocn_sal','Sa',loc_year,1,0,'',1.0,-2.0,2.0,40,'','plot_fields_SETTINGS_ANOM',[loc_str_exp '.sal.AMON']);
%   loc_data = str.statm_m;
%   data(n).array(y,x) = data(n).scale*loc_data;
%   % extract and compare ocean [PO4] to observations
%   n = n + 1;
%   n_BESTS(1) = n;
%   str = plot_fields_biogem_3d_k(loc_str_exp,'worlg4.WOA13_PO4_molkg-1_worlg4.151208.nc','ocn_PO4','PO4',loc_year,1,0,'',1.0E-6,-0.5,0.5,40,'','plot_fields_SETTINGS_ANOM',[loc_str_exp '.PO4.AMON']);
%   loc_data = str.statm_m;
%   data(n).array(y,x) = data(n).scale*loc_data;
%   % extract and compare ocean [O2] to observations
%   n = n + 1;
%   n_BESTS(2) = n;
%   str = plot_fields_biogem_3d_k(loc_str_exp,'worlg4.WOA13_O2_molkg-1_worlg4.151208.nc','ocn_O2','O2',loc_year,1,0,'',1.0E-6,-20.0,20.0,40,'','plot_fields_SETTINGS_ANOM',[loc_str_exp '.O2.AMON']);
%   loc_data = str.statm_m;
%   data(n).array(y,x) = data(n).scale*loc_data;
%
%   ***********************************************************************
%   *** HISTORY ***********************************************************
%   ***********************************************************************
%
%   26/01/18: adapted from fun_process_ensemble_2d to 3d
%
%   ***********************************************************************

% *********************************************************************** %
% *** INITIALIZE PARAMETERS & VARIABLES ********************************* %
% *********************************************************************** %
%
% *** initialize ******************************************************** %
%
% copy passed paramater structure
sin = DUM_S;
% get directory listing of ensemble member folders
struct_dir = dir([sin.str_expdir '/' sin.str_ensname '*']);
% set date
str_date = [datestr(date,11), datestr(date,5), datestr(date,7)];
% create empty 'best' vector
n_BESTS = [];
% initialize parameter processing count
m = 0;
% initialize axes
splot.xticks = {};
splot.yticks = {};
splot.zticks = {};
%
% *** initialize -- user options **************************************** %
%
% user-options for ensemble
str_sep  = '.';   % seperator string (if any) between str_ensemble and ##
str_data = '';    % data file name (if any)
% user-options for axis labels (default strings will be set if empty)
splot.xlabel = '';
splot.ylabel = '';
splot.zlabel = '';
% seed dimensions
xmax=1;
ymax=1;
zmax=1;
%
% *** initialize -- extract ensemble info and populate axes ************* %
%
% NOTE: dimension length is equal to number of variables minus one
%       (becasue the first is the parameter name)
loc_params = fileread(sin.str_ensname);
loc_params = regexp(loc_params, '\n', 'split');
n_dim      = length(loc_params);
for n=[1:n_dim]
    loc_str = char(loc_params(n));
    if (~isempty(loc_str))
        loc_c = textscan(loc_str,'%s');
        loc_c = loc_c{1};
        n_var = length(loc_c);
        if (n == 1) 
            if (isempty(splot.xlabel)) splot.xlabel = char(loc_c{1}); end
            splot.xticks = char(loc_c{2:n_var}); 
            xmax = n_var - 1;
        end
        if (n == 2) 
            if (isempty(splot.ylabel)) splot.ylabel = char(loc_c{1}); end
            splot.yticks = char(loc_c{2:n_var}); 
            ymax = n_var - 1;
        end
        if (n == 3)
            if (isempty(splot.zlabel)) splot.zlabel = char(loc_c{1}); end
            splot.zticks = char(loc_c{2:n_var});
            zmax = n_var - 1;
        end
    end
end
%
% --- STEP #1 ----------------------------------------------------------- %
% define time-series variables to extract and plot
% -- see help for examples
% NOTE: remember that m must be incremented by 1 for each added variable
% \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
% global mean temp
m = m+1;
data(m).dataname = 'ocn_temp';
data(m).datacol  = 2;
data(m).scale    = 1.0;
data(m).dataunit = '(oC)';
data(m).minmax   = [0 20];
% global mean [O2]
m = m+1;
data(m).dataname = 'ocn_O2';
data(m).datacol  = 3;
data(m).scale    = 1.0E+6;
data(m).dataunit = '(umol kg-1)';
data(m).minmax   = [100 300];
% /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
%
% set number of time-series data
n_par_ts = m;
%
% --- STEP #2 ----------------------------------------------------------- %
% define netCDF variables to extract and plot/analyse
% -- see help for examples
% NOTE: remember that m must be incremented by 1 for each added variable
% \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
% /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
%
% *** initialize -- process user options ******************************** %
%
% double-check variables have been requested!
if (~exist('data'))
    % ERROR
    disp([' ** ERROR: Define some variable to extract!']);
    disp([' ']);
    return;
end
% set total number of data
n_par = m;
% double-check (defined) number of requested variables
if (n_par ~= length(data))
    % ERROR
    disp([' ** ERROR: Inconsistency in the number of defined variables to process']);
    disp([' ']);
    return;
end
% set year to extract
loc_years   = num2cell(repmat(sin.year,1,n_par));
[data.year] = loc_years{:};
%
% *** set up results arrays ********************************************* %
%
% create an array of zeros associated with each parameter
for n=1:n_par
    data(n).array = zeros(ymax,xmax);
end
%
% *********************************************************************** %

% *********************************************************************** %
% *** EXTRACT RESULTS AND PROCESS ENSEMBLE ****************************** %
% *********************************************************************** %
%
% loop through each (x,y,z) ensemble pair
% NOTE: ensemble member numbers now count up from ONE!
%       (and are in base16 ...)
% NOTE: (x,y,z) == (m,n,o)
% >>>>
for z=1:zmax
    % >>>>
    for y=1:ymax
        % >>>>
        for x=1:xmax
            %
            % *** prepare results directory ***************************** %
            %
            % re-create experiment name
            loc_str_exp = [sin.str_ensname '.' hex2str(z) hex2str(y) hex2str(x)];
            disp([' >> exp == ' loc_str_exp]);
            % test for occurrence of tar.gz extension
            if exist([sin.str_expdir '/' loc_str_exp],'dir')
                loc_flag_unpack      = false;
                loc_flag_exptmissing = false;
            elseif exist([sin.str_expdir '/' [loc_str_exp sin.str_archext]],'file')
                disp(['    UN-PACKING ...']);
                untar([sin.str_expdir '/' [loc_str_exp sin.str_archext]],sin.str_expdir);
                loc_flag_unpack      = true;
                loc_flag_exptmissing = false;
            else
                % ERROR (report as 'warning' and keep going)
                disp([' ** WARNING: Cannot find either results directory or archive file of experiment: ' loc_str_exp]);
                disp([' ']);
                loc_flag_unpack      = false;
                loc_flag_exptmissing = true;
            end
            %
            % *** extract specific variables **************************** %
            %
            % NOTE: the specified (time-slice) year is looked for
            %       and incomplete/crashed/missing runs are assigned NaN
            % NOTE: loc_flag_exptmissing does not have to be used explicitly
            %       (becasue missing files and time-slices are tested for)
            for n=1:n_par_ts
                % set filename
                loc_str_file = [sin.str_tsroot '_' data(n).dataname sin.str_tsext];
                % test for file
                if exist([sin.str_expdir '/' loc_str_exp '/' sin.str_resdir '/' loc_str_file],'file')
                    % read data
                    loc_array = load([sin.str_expdir '/' loc_str_exp '/' sin.str_resdir '/' loc_str_file],'ascii');
                    loc_data_i = find(loc_array(:,1) == data(n).year);
                    if ~isempty(loc_data_i)
                        loc_data = loc_array(loc_data_i,data(n).datacol);
                        % test for data difference request
                        if (isfield(data,'datacolD'))
                            if (~isempty(data(n).datacolD))
                                loc_data = loc_data - loc_array(loc_data_i,data(n).datacolD);
                            end
                        end
                        % write data
                        data(n).array(z,y,x) = data(n).scale*loc_data;
                    else
                        data(n).array(z,y,x) = NaN;
                        disp([' ** WARNING: Cannot find time-point: ' num2str(data(n).year)]);
                    end
                else
                    data(n).array(z,y,x) = NaN;
                    disp([' ** WARNING: Cannot find file: ' [sin.str_expdir '/' loc_str_exp '/' sin.str_resdir '/' loc_str_file]]);
                end
            end
            %
            % *** process 3D netCDF ************************************* %
            %
            if (n_par > n_par_ts)
                n = n_par_ts;
                if loc_flag_exptmissing
                    % missing experiments => set all NaNs for results
                    for n=n_par_ts+1:n_par
                        data(n).array(z,y,x) = NaN;
                    end
                else
                    % --- STEP #4b -------------------------------------- %
                    % extract and plot/analyse netCDF variables
                    % \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
                    % /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
                    if (n ~= n_par)
                        % ERROR (fatal)
                        disp([' ** ERROR: Inconsistency in the number of processed variables']);
                        disp([' ']);
                        return;
                    end
                end
            end
            %
            % *** clean up ********************************************** %
            %
            % remote unpacked dir
            if loc_flag_unpack
                disp(['    REMOVE DIR']);
                rmdir([sin.str_expdir '/' loc_str_exp],'s');
            end
            %
            % *********************************************************** %
            %
        end
        % <<<<
    end
    % <<<<
end
% <<<<
%
% *********************************************************************** %

% *********************************************************************** %
% *** PLOT 2D ENSEMBLE DATA ********************************************* %
% *********************************************************************** %
%
if (zmax == 1)
    % create gridded plots of ensemble
    % NOTE: PRESCRIBED SCALE
    % NTOE: use squeeze to turn 1xYxX -> YxX
    for n=1:n_par
        % test for data difference request (and modify filename)
        if (isfield(data,'datacolD'))
            if (~isempty(data(n).datacolD))
                data(n).dataname = ['D' data(n).dataname];
            end
        end
        % construct filename and create plot
        splot.filename = [sin.str_outname  '.' data(n).dataname '.' num2str(data(n).datacol)];
        splot.unitslabel = data(n).dataunit;
        plot_2dgridded2(squeeze(data(n).array(1,:,:)),data(n).minmax,'',splot);
        % save data
        % NOTE: y-axis is opposite to as displayed in the plot
        %      (counting rows down)
        fprint_2DM(data(n).array(1,:,:),[],[splot.filename '.dat'],'%10.4f','%10.4f',true,false);
    end
end
%
% *********************************************************************** %

% *********************************************************************** %
% *** ANALYSE BEST(S) *************************************************** %
% *********************************************************************** %
%
for n=1:length(n_BESTS)
    %
    n_BEST = n_BESTS(n);
    %
    % *** find best ensemble member ************************************* %
    %
    mss_BEST = max(max(data(n_BEST).array)); % best model skill score
    I = find(data(n_BEST).array == mss_BEST);
    [n_z,n_y,n_x] = ind2sub([zmax ymax xmax],I);
    %
    % *** print best stats ********************************************** %
    %
    fid = fopen([str_outname '.' data(n_BEST).dataname '.' num2str(n_z) num2str(n_y) num2str(n_x) '.STATS.txt'], 'wt');
    fprintf(fid, '\n');
    fprintf(fid, '=== MSS STATS SUMMARY === \n');
    fprintf(fid, '\n');
    fprintf(fid, 'Best (x,y) : %d %d \n', n_z,n_y,n_x);
    fprintf(fid, '(ensemble notation: .%d%d ) \n', n_z,n_y,n_x);
    fprintf(fid, 'Best %s %s \n', char(splot.xlabel),char(splot.xticks(n_x)));
    fprintf(fid, 'Best %s %s \n', char(splot.ylabel),char(splot.yticks(n_y)));  
    fprintf(fid, 'Best %s %s \n', char(splot.zlabel),char(splot.zticks(n_z)));   
    fprintf(fid, '\n');
    fprintf(fid, '------------------------- \n');
    for n=1:n_par
        fprintf(fid, [data(n).dataname ' = %8.4f \n'], data(n).array(n_z,n_y,n_x));
    end
    fprintf(fid, '------------------------- \n');
    fprintf(fid, 'BEST: \n');
    fprintf(fid, [data(n_BEST).dataname ' = %8.4f \n'], data(n_BEST).array(n_z,n_y,n_x));
    fprintf(fid, '------------------------- \n');
    fprintf(fid, '\n');
    fprintf(fid, '========================= \n');
    fprintf(fid, '\n');
    fclose(fid);
    %
    % *** prepare results directory ************************************* %
    %
    % NOTE: we already know that the 'best' experiment must exist!
    % re-create experiment name
    loc_str_exp = [str_ensemble '.' num2str(n_z) num2str(n_y) num2str(n_x)];
    % test for occurrence of tar.gz extension
    if exist([str_dir '/' loc_str_exp],'dir')
        loc_flag_unpack = false;
    elseif exist([str_dir '/' [loc_str_exp str_archive]],'file')
        disp(['    UN-PACKING ...']);
        untar([str_dir '/' [loc_str_exp str_archive]],str_dir);
        loc_flag_unpack = true;
    else
        % ERROR
        disp([' ** ERROR: Cannot find either results directory or archives file of experiment: ' loc_str_exp]);
        disp([' ']);
        return;
    end
    %
    % *** analyse ******************************************************* %
    %
    loc_str_name = [str_name '.' data(n_BEST).dataname '.' num2str(n_z) num2str(n_y) num2str(n_x)];
    %
    % *** clean up ****************************************************** %
    %
    % (optional) remove unpacked dir
    if loc_flag_unpack
        disp(['    KEEP UNPACKED BEST RUN!']);
        %     disp(['    REMOVE DIR']);
        %     rmdir([str_dir '/' loc_str_exp],'s');
    end
    %
    % ******************************************************************* %
    %
end
%
% *********************************************************************** %

% *********************************************************************** %
% *** END *************************************************************** %
% *********************************************************************** %
%
%
close all;
%
% *********************************************************************** %
