function [ para ] = para_Pick(  )

% set default parameters for y_crazyseismic_Pick

%% Figure and text setting
% default fontsize and fontname
set(0,'defaultaxesfontsize',12);
set(0,'defaultaxesfontname','Helvetica');
set(0,'DefaultaxesFontweight','Bold');
set(0,'defaulttextfontsize',12);
set(0,'defaulttextfontname','Helvetica');
set(0,'DefaulttextFontweight','Bold');
set(0,'DefaultUicontrolFontsize',12);
set(0,'DefaultUicontrolFontname','Helvetica');
set(0,'DefaultUicontrolFontweight','Bold');
set(0,'DefaultUipanelFontsize',12);
set(0,'DefaultUipanelFontname','Helvetica');
set(0,'DefaultUipanelFontweight','Bold');
set(0,'DefaultUicontrolUnits','normalized');
set(0,'Defaultlinelinewidth',1);

% define line width, color, marker, markersize
para.bcolor = 0.9*[1 1 1]; % edit box background color
para.color_show = [0 0 0]; % color for regular traces
para.color_selected = [1 0 0]; % color for selected trace s
para.color_wig_up = [0 0 0]; % positive wiggle color
para.color_wig_dn = 0.7*[1 1 1]; % negative wiggle color
para.linewidth_show = 1; % line width of regular traces
para.linewidth_selected = 1.5; % line width of selected traces
para.marker_theo = 'v'; % theoretical arrival time marker
para.color_theo = 'm'; % color of theoretical arrival time marker
para.msize_theo = 5; % theoretical arrival time marker size


%% Seismic phases, velocity model and travel times
% Reference 1D Earth model for trave time calculating. you can choose
% 'ak135', 'prem', 'iasp91', or others defined in set_vmodel_v2.m. 
para.mod = 'ak135';
para.phase = 'PS';
para.data = '1';

%% Input and output files
% Input
% List of events - full path
para.evlist = 'eventid_sub.lst';
[para.evpathname, name1, name2] = fileparts(para.evlist);
para.evlistname = [name1,name2];
% para.PSlist = 'thero_PS_SP';
% List of sacfiles (stored in each event directory)
para.listname = 'list_z';
% Output
% parameter output file for each event
para.paraoutfile = 'outpara.txt';

%% Traces and time windows
% Number of traces per frame
para.n_per_frame = 100;
% Sampling rate (in seconds)
para.delta = 0.1;
% Trace time window (to read, in seconds, relative to the phase arrival time)
para.timewin = [-5 75];
para.timemax = 140;
para.timemin = 10;
% Trace freq range
para.freq_up = 15;
para.freq_up_max = 15;
para.freq_up_min = 5;
para.freq_lower = 0.8;
para.freq_lower_max = 4.8;
para.freq_lower_min = 0.5;
% Trace amplitude range
para.amplit = [0 50];
para.amplit_upper = 6000;
para.amplit_lower = 5;
% Trace time window (to show, in seconds, relative to the phase arrival time)
para.x_lim = para.timewin/2;
% Trace normalizaton window;
para.normwin = para.timewin;
% Trace sort type
para.sort_type = 'dist'; % dist, baz, snr, stla, stlo
% Trace plot type
para.plot_type = 'trace'; % trace or wiggles
% Trace normalization type. 'each' - each trace normalized by itself; 'all'
% - all traces normalized by the same scale.
para.norm_type = 'each';
% filter type and bandwidth, set fl=0 for low pass filter, and fh=0 for
% high pass filter. 'Two-Pass' for two pass butterworth filter; 'Min-Phase'
% for minimum phase filter
para.filter_type = 'BP';
para.fl = 0.5; % low frequency (Hz)
para.fh = 15; % high frequency (Hz)
para.order = 4; % order of the filter
para.passes = 1; % passes of the filter
% Trace amplitude scale
para.scale = 1;
% text parameters
para.text_para = {'dist','baz'};
% Pca type1: 'all': for all traces of current event; 'select': for selected
% traces only; 'frame': for traces in the current frame; 
para.pca_type1 = 'all'; 
% Pca type2: 'raw': for raw data; 'filter': for filtered data
para.pca_type2 = 'raw';


%% Plot switches and labels
para.theo_switch = 0; % whether plot theoretical arrvial time, 0 not plot
para.phase_show = 0; % whether mark phases
para.xy_switch = 0; % whether change X-Y axis
para.even_switch = 0; % whether evenly distribute
para.xlabel_name = 'Time (s)'; % xlabel
% para.ylabel_name = para.sort_type; % ylabel
% para.ylabel_name_backup = para.ylabel_name; % ylabel backup


%% lists
% phase list
para.phaselist  = {
    'PS';
    'Guided P';
    'SP';
    'S';
    'P';
    };
% data list
para.datalist = {
    '1';
    '2';
    '3';
    '4';
    '11';
    '22';
    };
% sort list
para.sortlist = {
    'dist';
    'az';
    'baz';
    'stanm';
    'evtnm';
    'evdp';
    };

% filter type
para.filtertype_list = {
    'BP'; %  Band-pass filter
    'BS'; %  Band-stop filter
    'LP'; %  Low-pass filter
    'HP'; %  High-pass filter
    
 %   'Min-Phase'
    };

% text parameters
para.text_list = {
    'dist';
    'az';
    'baz';
    'stanm';
    'evtnm';
    'evdp';
    };
    

% listbox type
para.listbox_list = {
    'nstnm';
    'stnm';
    'fname';
    };

para.r2d = 180/pi; % radius to degree convertion parameter
para.cmap = colormap(jet); % color map for plotting sprectra

end

