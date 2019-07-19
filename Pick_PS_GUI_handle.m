function Pick_PS_GUI_handle
%% pick PS-GUI 
%% add path
addpath(genpath(pwd));
%% Import parameters
para = para_PS;

%% Main program
%% Figure setup
handle.f1 = figure('Toolbar','figure','Units','normalized','keypressfcn', @Pick_short_cut,'Position',[.0 .0 1.0 1.0]);
set(handle.f1,'name','PS/SP Pick','NumberTitle','off');
handle.hax{1} = axes('pos',[.25 .515 .315 .48]);
[hex_upper{1}, hex_lower{1}] = create_handle(handle.hax{1}); 
set(handle.hax{1},'YTickLabel',[]);
set(handle.hax{1},'XTickLabel',[]);
hold(handle.hax{1},'on');
% box(handle.hax{1},'off');
handle.hax{2} = axes('pos',[.565 .515 .315 .48]);
[hex_upper{2}, hex_lower{2}] = create_handle(handle.hax{2}); 
set(handle.hax{2},'YTickLabel',[]);
set(handle.hax{2},'XTickLabel',[]);
%box(handle.hax{2},'off');
hold(handle.hax{2},'on');
handle.hax{3} = axes('pos',[.25 .01 .315 .48]);
[hex_upper{3}, hex_lower{3}] = create_handle(handle.hax{3}); 
set(handle.hax{3},'YTickLabel',[]);
set(handle.hax{3},'XTickLabel',[]);
%box(handle.hax{3},'off');
hold(handle.hax{3},'on');
handle.hax{4} = axes('pos',[.565 .01 .315 .48]);
%box(handle.hax{4},'off');
[hex_upper{4}, hex_lower{4}] = create_handle(handle.hax{4}); 
set(handle.hax{4},'YTickLabel',[]);
set(handle.hax{4},'XTickLabel',[]);
hold(handle.hax{4},'on');


% hotkeys setup
handle.h_hot = uicontrol('String','<html><b>Pick PS/SP</b></html','keypressfcn',@Pick_short_cut,'Position',[.12 .95 .12 .04]);

%% plot panel
plot_panel = uipanel('parent',handle.f1,'title','Plot','Position',[0.12 .31 .12 .64]);
% event list
data_ind = find(strcmp(para.datalist,char(para.data)));
if ~data_ind
    fprintf('No data file %s in the list\n',para.data); return;
end
uicontrol(plot_panel,'Style','text','String','Data list','Position',[.0 .96 .4 .04]);
handle.h_data_list = uicontrol(plot_panel,'Style','popupmenu','String',para.datalist,'callback',@Pick_callback_choosedata,'Value',data_ind,'Position',[.4 .96 .4 .04]);
% load data 
uicontrol(plot_panel,'String','Load data(l)','callback',@Pick_callback_loaddata,'Position',[.1 .85 .8 .1]);
% find the default phase name
ind = find(strcmp(para.phaselist,para.phase));
if ~ind
    fprintf('No phase %s in the list\n',para.phase); return;
end
uicontrol(plot_panel,'Style','text','String','Phase','Position',[.0 .8 .4 .04]);
handle.h_phase_list = uicontrol(plot_panel,'Style','popupmenu','String',para.phaselist,'callback',@Pick_callback_choosephase,'Value',ind,'Position',[.4 .8 .4 .04]);

% find the sort type of the sac files
ind_sort = find(strcmp(para.sortlist,para.sort_type));
if ~ind_sort 
    fprintf('No sort_type %s in the list\n',para.sort_type); return;
end
uicontrol(plot_panel, 'Style','text','String','Sort','Position',[.0 .75 .4 .04]);
handle.h_sort_list = uicontrol(plot_panel, 'Style', 'popupmenu','String',para.sortlist,'callback',@Pick_callback_sort,'Value',ind_sort,'Position',[.4 .75 .4 .04]);

% filtering
uicontrol(plot_panel, 'Style','pushbutton','String','Filter','callback',@Pick_callback_filter,'Position', [.05 .70 .3 .04]);
% find filter type
ind_filter = find(strcmp(para.filtertype_list,para.filter_type));
if ~ind_filter
    fprintf('No filter_type %s in the list\n',para.filter_type); return;
end
handle.h_filter_type = uicontrol(plot_panel,'Style','popupmenu','String',para.filtertype_list,'Value',ind_filter,'Position',[.4 .70 .4 .04]);
uicontrol(plot_panel,'Style','text','String','Lowf','Position',[.0 .65 .4 .04]);
handle.h_filter_fl = uicontrol(plot_panel,'Style','edit','String',num2str(para.fl),'Position',[.4 .65 .4 .04],'BackgroundColor',para.bcolor);
uicontrol(plot_panel,'Style','text','String','Highf','Position',[.0 .60 .4 .04]);
handle.h_filter_fh = uicontrol(plot_panel,'Style','edit','String',num2str(para.fh),'Position',[.4 .60 .4 .04],'BackgroundColor',para.bcolor);
uicontrol(plot_panel,'Style','text','String','Order','Position',[.0 .55 .4 .04]);
handle.h_order = uicontrol(plot_panel,'Style','edit','String',num2str(para.order),'Position',[.4 .55 .4 .04],'BackgroundColor',para.bcolor);
uicontrol(plot_panel,'Style','text','String','Passes','Position',[.0 .50 .4 .04]);
handle.h_passes = uicontrol(plot_panel,'Style','edit','String',num2str(para.passes),'Position',[.4 .50 .4 .04],'BackgroundColor',para.bcolor);
% the time range
uicontrol(plot_panel, 'Style', 'text', 'String', 'Time Range','Position',[.0 .45 .35 .04]);
handle.h_range = uicontrol(plot_panel,'Style','slider','Value',para.timewin(2),'Max',para.timemax,'Min',para.timemin,'callback',@Pick_callback_range,'Position',[0.35 0.45 0.6 0.04],'Sliderstep',[0.2 0.5]);

% the frequency range
uicontrol(plot_panel, 'Style', 'text', 'String', 'Plotted Frequency Range','Position',[.1 .40 .8 .04]);
uicontrol(plot_panel, 'Style', 'text', 'String', 'Upper','Position',[.0 .35 .4 .04]);
handle.h_freq_range_upper = uicontrol(plot_panel,'Style','slider','Value',para.freq_up, 'Max',para.freq_up_max, 'Min',para.freq_up_min,'callback',@Pick_callback_freq_up, 'Position', [0.35 0.35 0.6 0.04],'Sliderstep',[0.1 0.4]);
uicontrol(plot_panel, 'Style', 'text', 'String', 'Lower','Position',[.0 .3 .4 .04]);
handle.h_freq_range_lower = uicontrol(plot_panel,'Style','slider','Value',para.freq_lower,'Max',para.freq_lower_max,'Min',para.freq_lower_min,'callback',@Pick_callback_freq_lower,'Position', [0.35 0.3 0.6 0.04],'Sliderstep',[0.2 0.5]);

% the amplitude range
uicontrol(plot_panel, 'Style','text', 'String', 'Plotted Amplitude Range', 'Position',[.1 .25 .8 0.04]);
handle.h_amplit_range = uicontrol(plot_panel,'Style','slider','Value',para.amplit(2), 'Max',para.amplit_upper, 'Min',para.amplit_lower, 'callback',@Pick_callback_amplit, 'Position', [0.1 0.2 0.8 0.04],'Sliderstep',[0.001 0.04]);

% initiate to plot the figure
uicontrol(plot_panel,'String','Start to plot(i)','callback',@Pick_callback_plot_initial,'Position',[.1 .1 .8 .1]);

% choose event forward or backward
uicontrol(plot_panel,'String','Pre_ev(b)','callback',@Pick_callback_preevent,'Style','pushbutton','Position',[0.1 0.01 0.4 0.1]);
uicontrol(plot_panel,'String','Next_ev(n)','callback',@Pick_callback_nextevent,'Style','pushbutton','Position',[0.5 0.01 0.4 0.1]);

%% station panel
sta_panel = uipanel('parent',handle.f1, 'title', 'Station for each event','Position',[0.12 0.21 0.12 0.1]);
uicontrol(sta_panel,'String','Pre_sta(,)','callback',@Pick_callback_prestation,'Style','pushbutton','Position', [0.1 0.5 0.4 0.5]);
uicontrol(sta_panel,'String','Next_sta(.)','callback',@Pick_callback_nextstation,'Style','pushbutton','Position', [0.5 0.5 0.4 0.5]);
uicontrol(sta_panel,'String','1st_sta','callback',@Pick_callback_firststation,'Style','pushbutton','Position', [0.1 0.0 0.4 0.5]);
uicontrol(sta_panel,'String','Last_sta','callback',@Pick_callback_laststation,'Style','pushbutton','Position', [0.5 0.0 0.4 0.5]);
%% I/O panel
io_panel = uipanel('parent', handle.f1, 'title', 'I/O','Position',[0.12 .13 .12 .08]);
% load the sac dir
uicontrol(io_panel,'callback',@Pick_callback_load_sacdir,'String','Load SAC Files','Position',[0.01 0.1 0.49 0.9]);
uicontrol(io_panel,'callback',@Pick_callback_save_sacdir,'String','Save files','Position',[0.51 0.1 0.49 0.9]);
%% Replot panel
replot_panel = uipanel('parent',handle.f1, 'title','Subplot','Position',[0.12 0.07 0.12 0.06]);
uicontrol(replot_panel,'callback',@Pick_callback_replot_1,'String','replot 1','Position',[0.01 0.01 0.25 0.9]);
uicontrol(replot_panel,'callback',@Pick_callback_replot_2,'String','replot 2','Position',[0.26 0.01 0.25 0.9]);
uicontrol(replot_panel,'callback',@Pick_callback_replot_3,'String','replot 3','Position',[0.51 0.01 0.25 0.9]);
uicontrol(replot_panel,'callback',@Pick_callback_replot_4,'String','replot 4','Position',[0.76 0.01 0.25 0.9]);
%% Pick panel
pick_panel = uipanel('parent',handle.f1,'title','Pick','Position',[0.12 0.01 0.12 0.06]);
uicontrol(pick_panel,'callback',@Pick_callback_pick,'String','Pick(p)','Position',[0.005 0.01 0.245 0.9]);
uicontrol(pick_panel,'callback',@Pick_callback_reset,'String','Reset(r)','Position',[0.255 0.01 0.245 0.9]);
uicontrol(pick_panel,'callback',@Pick_callback_delete,'String','Delete(d)','Position',[0.505 0.01 0.245 0.9]);
uicontrol(pick_panel,'callback',@Pick_callback_save_figure,'String','Save(s)','Position',[0.755 0.01 0.245 0.9]);
%% The station-event pair figure plot
sta_eve_panel{1} = uipanel('parent',handle.f1, 'title','leftup(1)','Position',[0.005 0.5 0.115 0.5]);
handle.im{1} = axes('parent',sta_eve_panel{1},'pos',[.001 .001 .998 0.998]);
sta_eve_panel{3} = uipanel('parent',handle.f1, 'title','leftbottom(3)','Position',[0.005 0.0 0.115 0.5]);
handle.im{3} = axes('parent',sta_eve_panel{3},'pos',[.001 .001 .998 0.998]);
sta_eve_panel{2} = uipanel('parent',handle.f1, 'title','rightup(2)','Position',[0.885 0.5 0.115 0.5]);
handle.im{2} = axes('parent',sta_eve_panel{2},'pos',[.001 .001 .998 0.998]);
sta_eve_panel{4} = uipanel('parent',handle.f1, 'title','rightbottom(4)','Position',[0.885 0.0 0.115 0.5]);
handle.im{4} = axes('parent',sta_eve_panel{4},'pos',[.001 .001 .998 0.998]);

%% create handle functions
function [h1, h2] = create_handle(h0)
    op = get(h0,'position');
    NUMCOLS = 1; % widths for each subplot
    nrows = 3; % hights for each subplot
    pwidth=op(3)/NUMCOLS;
    height=op(4)/nrows;
    leftb = zeros(  round(((op(1)+op(3)-pwidth) - op(1))/pwidth) + 1, 1 );
    for i = 1:1:length(leftb)
        leftb(i) = op(1) + (i-1)*pwidth;
    end
    leftb=leftb(ones(nrows,1),:)';
    bottom=op(2):height:op(2)+op(4)-height;
    bottom=flipud(bottom(ones(NUMCOLS,1),:)')';
    cla(h0,'reset');
    % the set up of subplot
    sh=0.6;
    sw=0.9;
    tpl=min([0.02 (1-sh)*height sh*height sw*pwidth (1-sw)*pwidth]);
    jt=2/3*tpl;
%     cbw=0.02;
    % creater handles for subplot
    for i = 1:1:nrows
        h1{i}=axes(...
                'outerposition',[leftb(i) bottom(i)+sh*height ...
                sw*pwidth (1-sh)*height],...
                'position',[leftb(i)+tpl+0.01 bottom(i)+sh*height ...
                sw*pwidth-tpl (1-sh)*height-jt],...
                'ydir','normal','xdir','normal','color','w',...
                'fontsize',10,'fontweight','bold',...
                'xcolor','w','ycolor','w');
        h2{i}=axes(...
                'outerposition',...
                [leftb(i) bottom(i) sw*pwidth sh*height],...
                'position',[leftb(i)+tpl+0.01 bottom(i)+tpl ...
                sw*pwidth-tpl sh*height-tpl],...
                'ydir','normal','xdir','normal','color','w',...
                'fontsize',10,'fontweight','bold',...
                'xcolor','w','ycolor','w');
    end
            
    
end

% calculate the theoretical times for PS and SP wave

        
%% callback functions
function Pick_callback_choosedata(h, dummy)
    uicontrol(handle.h_hot);
    list_data = get(handle.h_data_list,'String');
    index_data = get(handle.h_data_list,'Value');
    para.data = list_data{index_data};
    fprintf('Data eventid_sub%s.lst selected!\n',para.data);
    [para.evpathname, name1, name2] = fileparts(para.evlist);
    para.evlistname = [name1,para.data,name2];
    para.PSlist = 'thero_PS_SP';
    para.PSlist = [para.PSlist, para.data];
end

function Pick_callback_loaddata(h, dummy)
    % load in data
    tic
    uicontrol(handle.h_hot)    
    
    % check event list
    if ~exist(para.evlistname,'file')
        fprintf('Eventlist %s not found!\n',para.evlistname);
        para.evlistname = [];
       % para.ievent = 1;
%         cla(handle.hax,'reset');
%         set(handle.h_listbox,'String',[]);
        return;
    else
        fid = fopen(para.evlistname, 'r');
        y_dim = 8;
        x_dim = 400;
        para.events = cell(x_dim,y_dim);
        i = 0;
        while (~feof(fid))
            C = textscan(fid,'%s',y_dim);
            if isempty(C{1})
                break;
            end
            if ( ~strcmp(char(C{1}(1)),'ORID') )
                i = i + 1;
                for j = 1:1:y_dim
                    para.events{i,j} = C{1}(j);
                end
            end
        end
        fclose(fid);
        para.nevent = i;
        para.events([i+1:end],:) = [];
        para.ievent = 1;
        para.istation = 1;
        fprintf('Event list %s loaded!\n',para.evlistname);
        if exist('recentplot.mat','file')
            lastrun = load('recentplot.mat');
            para.istation = lastrun.idx_istation;
            para.ievent = lastrun.idx_ievent;
        end
    end
    
    % read the thero calculated PS and SP time
    if ~exist(para.PSlist, 'file')
        fprintf('Thero calculated %s file not found!\n',para.PSlist);
        para.PSlist = [];
        cla(handle.hax, 'reset');
%         set(handle.h_listbox,'String',[]);
        return;
    else
        fid = fopen(para.PSlist, 'r');
        y_dim = 5;
        x_dim = 400*69;
        para.PSSP_cal = cell(x_dim,y_dim);
        i = 0;
        while (~feof(fid))
            C = textscan(fid,'%s',y_dim);
            if isempty(C{1})
                break;
            end
            i = i + 1;
            for j = 1:1:y_dim
                para.PSSP_cal{i,j} = cell2mat(C{1}(j));
            end
        end
        fclose(fid);
        para.maxrecord = i;
        para.PSSP_cal([i+1:end],:) = [];
        fprintf('Thero calculated %s loaded!\n',para.PSlist);
    end  
    toc
        

end

function Pick_callback_choosephase(h, dummy)
    
    uicontrol(handle.h_hot);
    list_phase = get(handle.h_phase_list, 'String');
    index_phase = get(handle.h_phase_list, 'Value');
    para.phase = list_phase{index_phase};
    fprintf('Phase %s selected!\n',para.phase);
    
    
end

function Pick_callback_sort(h, dummy)
    uicontrol(handle.h_hot);
    list_sort = get(handle.h_sort_list,'String');
    index_sort = get(handle.h_sort_list,'Value');
    para.sort_type = list_sort{index_sort};
    fprintf('Sort traces according to %s\n',para.sort_type);
    
end

function Pick_callback_filter(h, dummy)
    uicontrol(handle.h_hot);
    fl_temp = str2num(get(handle.h_filter_fl,'String'));
    fh_temp = str2num(get(handle.h_filter_fh,'String'));
    order_temp = str2num(get(handle.h_order,'String'));
    passes_temp = str2num(get(handle.h_passes,'String'));
    if ~isempty(fl_temp) && ~isempty(fh_temp) && isnumeric(order_temp) && isnumeric(passes_temp)
        para.fl = fl_temp;
        para.fh = fh_temp;
        para.order = order_temp;
        para.passes = passes_temp;
    else
        para.fl = 0;
        para.fh = 0;
        para.order = 0;
        para.passes = 0;
        fprintf('No filtering!\n');
    end
    
end

function Pick_callback_range(h, dummy)
    uicontrol(handle.h_hot);
    time_max = get(handle.h_range,'Value');
    para.timewin(2) = floor(time_max);
    fprintf('Time Range [%d,%d] selected!\n',para.timewin(:));
        
end

function Pick_callback_freq_up(h, dummy)
    uicontrol(handle.h_hot);
    freq_up = get(handle.h_freq_range_upper,'Value');
    para.freq_up = freq_up;
    fprintf('Plotted Frequency upper limit %f \n',para.freq_up);
end

function Pick_callback_freq_lower(h, dummy)
    uicontrol(handle.h_hot);
    freq_lower = get(handle.h_freq_range_lower,'Value');
    para.freq_lower = freq_lower;
    fprintf('Plotted Frequency lower limit %f \n',para.freq_lower);
end

function Pick_callback_amplit(h, dummy)
    uicontrol(handle.h_hot);
    amplit_upper = get(handle.h_amplit_range,'Value');
    para.amplit(2) = amplit_upper;
    fprintf('Plotted Amplitude range [%f,%f]\n',para.amplit(:));
end

function Pick_callback_load_sacdir(h, dummy)
    uicontrol(handle.h_hot);
    % find the sac file of event
    sacdir = uigetdir('Load SAC dir');
    para.sacdir = sacdir;
    fprintf('Sac Dir %s loaded!\n',para.sacdir);
end

function Pick_callback_save_sacdir(h, dummy)
    uicontrol(handle.h_hot);
    % find a place to save the sac files with the PS,SP,guideP,P,S
    % information updated
    savedir = uigetdir('Save SAC dir');
    para.PSdir = sprintf('%s/PickedPS',savedir);
    para.SPdir = sprintf('%s/PickedSP',savedir);
    para.PreGuidedPdir = sprintf('%s/PreGuidedP',savedir);
    para.ChangePdir = sprintf('%s/ChangeP',savedir);
    para.ChangeSdir = sprintf('%s/ChangeS',savedir);

    % find a place to store the figure that has PS, SP or guided P phase
    para.figure_PSdir = sprintf('%s/Figure/PickedPS',savedir);
    para.figure_SPdir = sprintf('%s/Figure/PickedSP',savedir);
    para.figure_GuidedPdir = sprintf('%s/Figure/GuidedP',savedir);
    para.figure_ChangePdir = sprintf('%s/Figure/ChangeP',savedir);
    para.figure_ChangeSdir = sprintf('%s/Figure/ChangeS',savedir);
    
    if ( exist(para.PSdir,'dir') == 0 )
        mkdir(para.PSdir);
    end
    if ( exist(para.SPdir,'dir') == 0 )
        mkdir(para.SPdir);
    end
    if ( exist(para.PreGuidedPdir,'dir') == 0 )
        mkdir(para.PreGuidedPdir);
    end
    if ( exist(para.ChangePdir,'dir') == 0 )
        mkdir(para.ChangePdir);
    end
    if ( exist(para.ChangeSdir,'dir') == 0 )
        mkdir(para.ChangeSdir);
    end
    if ( exist(para.figure_PSdir,'dir') == 0 )
        mkdir(para.figure_PSdir);
    end
    if ( exist(para.figure_SPdir,'dir') == 0 )
        mkdir(para.figure_SPdir);
    end
    if ( exist(para.figure_GuidedPdir,'dir') == 0 )
        mkdir(para.figure_GuidedPdir);
    end
    if ( exist(para.figure_ChangePdir,'dir') == 0 )
        mkdir(para.figure_ChangePdir);
    end
    if ( exist(para.figure_ChangeSdir,'dir') == 0 )
        mkdir(para.figure_ChangeSdir);
    end

end


function Pick_callback_plot_initial(h, dummy)
    uicontrol(handle.h_hot);
    ievent_dir = sprintf('%s/%s/%s_%s',para.sacdir,para.data,para.data,char(para.events{para.ievent,1}));
    sacname_list = dir(fullfile(ievent_dir,'*.sac'));
    sac_list = {sacname_list.name};
    [~, total_sac] = size(sac_list);
    para.istanumber = total_sac/3;
    ieve_sta = cell(total_sac,1);
    for i = 1:1:total_sac
        sta_temp = split(sac_list{i},'.');
        stan_temp = split(sta_temp{1},'_');
        ieve_sta{i} = stan_temp{3};
    end
    para.ieve_sta = unique(ieve_sta,'stable');
    % can add a function to show the station list
    if ~isfield(para,'istation')
        return;
    end
    % filter the sac data
    index_filtertype = get(handle.h_filter_type, 'Value');
    para.filter_type = para.filtertype_list{index_filtertype};
    
    for i = para.istation:1:(para.istation + 3)
        % plot the time series data and the spectra data
        % para.istation = i;
        ind_figure = mod(i,4);
        if ind_figure == 0
            ind_figure = 4;
        end
        if ( i > para.istanumber )
            para.sacdata{ind_figure} = {};
            cla(handle.hax{ind_figure},'reset');
            for j = 1:1:3
                cla(hex_upper{ind_figure}{j},'reset');
                cla(hex_lower{ind_figure}{j},'reset');
            end
%             delete(handle.hax{ind_figure},'');
            continue;
        end
        sacdata = readwithseismo(para.ieve_sta{i},ievent_dir);
        % get the time for the S time if there is any
        [t2,t9]=getheader(sacdata,'t2','t9');
        if ( t9 > 0 )
            time_range = [para.timewin(1) t2(1) + 15];
             
        else
            time_range = para.timewin;
        end
        
        filterdata = iirfilter(sacdata,para.filter_type,'butter','pcorner',[para.fl para.fh],'npoles',para.order,...
                    'passes',para.passes);

        cla(handle.hax{ind_figure},'reset'); 
        set(handle.hax{ind_figure},'YTickLabel',[]);
        set(handle.hax{ind_figure},'XTickLabel',[]);
%         axes(handle.hax{ind_figure});
        [x,fc] = ftan(filterdata,100,0,[],[],[para.freq_lower_min,para.freq_up_max],hex_upper{ind_figure}, hex_lower{ind_figure},...
            'Xlim',time_range,'FGCOLOR','k','BGCOLOR','w','colormap','k',...
            'Zlim',para.amplit,'FREQRANGE',[para.freq_lower,para.freq_up],...
            'ZCOLORMAP',para.cmap,'FONTSIZE',13,'FONTWEIGHT','normal','NUMCOLS',1,...
            'NFREQ',100,'NUMFREQ',200,'POSTFUNC',@abs,'MARKERS','true') ;  
       % set(h2,'yticklabel',[para.freq_lower,para.freq_up]);
        % plot the image of station and event setup
        imdata = readimage(para.ieve_sta{i},ievent_dir);
        image(handle.im{ind_figure},imdata);
        % store the initially read sac file in para.PS setup;
        para.sacdata{ind_figure} = sacdata; 
        % store the spectra for each sac file
        para.sacsptra_x{ind_figure} = x;
        para.sacsptra_fc{ind_figure} = fc;
        % plot the thero calculated PS and SP time
        imname = split(ievent_dir,'/');
        markphase(char(imname{end}), char(para.ieve_sta{i}),hex_lower{ind_figure}{3});
    end
    % reset the pick to empty
    para.xpick = [];
    para.ypick = [];
%     para.istation = 5;% the next seismogram for the first event is the fifth
    
end

function Pick_callback_replot_1(h, dummy)
    uicontrol(handle.h_hot);
    sacdata = para.sacdata{1};
    cla(handle.hax{1},'reset');
    set(handle.hax{1},'YTickLabel',[]);
    set(handle.hax{1},'XTickLabel',[]);
    if ( isempty(sacdata) )
        return;
    end
%     delete(get(handle.hax{1},'Children'));
%       axes(handle.hax{1});
    %% get the updated filter
    index_filtertype = get(handle.h_filter_type, 'Value');
    para.filter_type = para.filtertype_list{index_filtertype};
    filterdata = iirfilter(sacdata,para.filter_type,'butter','pcorner',[para.fl para.fh],'npoles',para.order,...
                    'passes',para.passes);
    %% get the updated time range and frequency range
    Pick_callback_freq_up(h, dummy);
    Pick_callback_freq_lower(h, dummy);
    Pick_callback_range(h, dummy);
    Pick_callback_amplit(h, dummy);
    % get the time for the S time if there is any
    [t2,t9]=getheader(sacdata,'t2','t9');
    if ( t9 > 0 )
        time_range = [para.timewin(1) t2(1) + 15];

    else
        time_range = para.timewin;
    end
    ftan(filterdata,100,1,para.sacsptra_x{1},para.sacsptra_fc{1},[para.freq_lower_min,para.freq_up_max],hex_upper{1}, hex_lower{1},...
            'Xlim', time_range,'FGCOLOR','k','BGCOLOR','w','colormap','k',...
            'Zlim',para.amplit,'FREQRANGE',[para.freq_lower,para.freq_up],...
            'ZCOLORMAP',para.cmap,'FONTSIZE',13,'FONTWEIGHT','normal','NUMCOLS',1,...
            'NFREQ',100,'NUMFREQ',200,'POSTFUNC',@abs,'MARKERS','true') ; 
    sta_ini = {sacdata.name};
    sta_temp = split(sta_ini(1),'.');
    sta_temp2 = split(sta_temp(1),'_');
    event_name = sprintf('%s_%s',char(sta_temp2(1)),char(sta_temp2(2)));
    sta_name = char(sta_temp2(3));
    markphase(event_name, sta_name,hex_lower{1}{3});
    drawnow;
    % reset the pick to empty
    
end

function Pick_callback_replot_2(h, dummy)
    uicontrol(handle.h_hot);
    sacdata = para.sacdata{2};
    cla(handle.hax{2},'reset');
    set(handle.hax{2},'YTickLabel',[]);
    set(handle.hax{2},'XTickLabel',[]);
    if ( isempty(sacdata) )
        return;
    end
%     axes(handle.hax{2});
    %% get the updated filter
    index_filtertype = get(handle.h_filter_type, 'Value');
    para.filter_type = para.filtertype_list{index_filtertype};
    filterdata = iirfilter(sacdata,para.filter_type,'butter','pcorner',[para.fl para.fh],'npoles',para.order,...
                    'passes',para.passes);
    %% get the updated time range and frequency range
    Pick_callback_freq_up(h, dummy);
    Pick_callback_freq_lower(h, dummy);
    Pick_callback_range(h, dummy);
    Pick_callback_amplit(h, dummy)
    [t2,t9]=getheader(sacdata,'t2','t9');
    if ( t9 > 0 )
        time_range = [para.timewin(1) t2(1) + 15];

    else
        time_range = para.timewin;
    end
    ftan(filterdata,100,1,para.sacsptra_x{2},para.sacsptra_fc{2},[para.freq_lower_min,para.freq_up_max],hex_upper{2}, hex_lower{2},...
            'Xlim',time_range,'FGCOLOR','k','BGCOLOR','w','colormap','k',...
            'Zlim',para.amplit,'FREQRANGE',[para.freq_lower,para.freq_up],...
            'ZCOLORMAP',para.cmap,'FONTSIZE',13,'FONTWEIGHT','normal','NUMCOLS',1,...
            'NFREQ',100,'NUMFREQ',200,'POSTFUNC',@abs,'MARKERS','true') ;  
    sta_ini = {sacdata.name};
    sta_temp = split(sta_ini(1),'.');
    sta_temp2 = split(sta_temp(1),'_');
    event_name = sprintf('%s_%s',char(sta_temp2(1)),char(sta_temp2(2)));
    sta_name = char(sta_temp2(3));
    markphase(event_name, sta_name,hex_lower{2}{3});  
    drawnow;
end

function Pick_callback_replot_3(h, dummy)
    uicontrol(handle.h_hot);
    sacdata = para.sacdata{3};
    cla(handle.hax{3},'reset');
    set(handle.hax{3},'YTickLabel',[]);
    set(handle.hax{3},'XTickLabel',[]);
    if ( isempty(sacdata) )
        return;
    end
%     axes(handle.hax{3});
    %% get the updated filter
    index_filtertype = get(handle.h_filter_type, 'Value');
    para.filter_type = para.filtertype_list{index_filtertype};
    filterdata = iirfilter(sacdata,para.filter_type,'butter','pcorner',[para.fl para.fh],'npoles',para.order,...
                    'passes',para.passes);
    %% get the updated time range and frequency range
    Pick_callback_freq_up(h, dummy);
    Pick_callback_freq_lower(h, dummy);
    Pick_callback_range(h, dummy);
    Pick_callback_amplit(h, dummy);
    [t2,t9]=getheader(sacdata,'t2','t9');
    if ( t9 > 0 )
        time_range = [para.timewin(1) t2(1) + 15];

    else
        time_range = para.timewin;
    end
    ftan(filterdata,100,1,para.sacsptra_x{3},para.sacsptra_fc{3},[para.freq_lower_min,para.freq_up_max],hex_upper{3}, hex_lower{3},...
            'Xlim',time_range,'FGCOLOR','k','BGCOLOR','w','colormap','k',...
            'Zlim',para.amplit,'FREQRANGE',[para.freq_lower,para.freq_up],...
            'ZCOLORMAP',para.cmap,'FONTSIZE',13,'FONTWEIGHT','normal','NUMCOLS',1,...
            'NFREQ',100,'NUMFREQ',200,'POSTFUNC',@abs,'MARKERS','true') ;  
    sta_ini = {sacdata.name};
    sta_temp = split(sta_ini(1),'.');
    sta_temp2 = split(sta_temp(1),'_');
    event_name = sprintf('%s_%s',char(sta_temp2(1)),char(sta_temp2(2)));
    sta_name = char(sta_temp2(3));
    markphase(event_name, sta_name,hex_lower{3}{3});    
    drawnow;
end

function Pick_callback_replot_4(h, dummy)
    uicontrol(handle.h_hot);
    sacdata = para.sacdata{4};
    cla(handle.hax{4},'reset');
    set(handle.hax{4},'YTickLabel',[]);
    set(handle.hax{4},'XTickLabel',[]);
    if ( isempty(sacdata) )
        return;
    end
%     axes(handle.hax{4});
    %% get the updated filter
    index_filtertype = get(handle.h_filter_type, 'Value');
    para.filter_type = para.filtertype_list{index_filtertype};
    filterdata = iirfilter(sacdata,para.filter_type,'butter','pcorner',[para.fl para.fh],'npoles',para.order,...
                    'passes',para.passes);
    %% get the updated time range and frequency range
    Pick_callback_freq_up(h, dummy);
    Pick_callback_freq_lower(h, dummy);
    Pick_callback_range(h, dummy);
    Pick_callback_amplit(h, dummy);
    [t2,t9]=getheader(sacdata,'t2','t9');
    if ( t9 > 0 )
        time_range = [para.timewin(1) t2(1) + 15];

    else
        time_range = para.timewin;
    end
    ftan(filterdata,100,1,para.sacsptra_x{4},para.sacsptra_fc{4},[para.freq_lower_min,para.freq_up_max],hex_upper{4}, hex_lower{4},...
            'Xlim',time_range,'FGCOLOR','k','BGCOLOR','w','colormap','k',...
            'Zlim',para.amplit,'FREQRANGE',[para.freq_lower,para.freq_up],...
            'ZCOLORMAP',para.cmap,'FONTSIZE',13,'FONTWEIGHT','normal','NUMCOLS',1,...
            'NFREQ',100,'NUMFREQ',200,'POSTFUNC',@abs,'MARKERS','true') ;  
    sta_ini = {sacdata.name};
    sta_temp = split(sta_ini(1),'.');
    sta_temp2 = split(sta_temp(1),'_');
    event_name = sprintf('%s_%s',char(sta_temp2(1)),char(sta_temp2(2)));
    sta_name = char(sta_temp2(3));
    markphase(event_name, sta_name, hex_lower{4}{3});   
    drawnow;
end

function markphase(event_name, sta_name , ax)
  %  uicontrol(handle.h_hot);
    % find the phase that need to be marked in the seimogram
    eventid = strcmp(para.PSSP_cal(:,1), char(event_name));
    eve_id = find(eventid == 1);
    stationid = strcmp(para.PSSP_cal(eve_id,2), char(sta_name));
    sta_id = find(stationid == 1);
    ps_cal_ak135 = str2num(cell2mat(para.PSSP_cal(eve_id(sta_id),3)));
    ps_cal_lau = str2num(cell2mat(para.PSSP_cal(eve_id(sta_id),4)));
    sp_cal = str2num(cell2mat(para.PSSP_cal(eve_id(sta_id),5)));
%     hold on;
    plot(ax, linspace(ps_cal_ak135,ps_cal_ak135,20),linspace( -0.3*(para.freq_up - para.freq_lower) + 0.5*(para.freq_lower + para.freq_up),...
        0.3*(para.freq_up - para.freq_lower) + 0.5*(para.freq_lower + para.freq_up), 20),...
        'color',[0,125,0]/256, 'linewidth',2);
    plot(ax,linspace(ps_cal_lau,ps_cal_lau,20),linspace( -0.3*(para.freq_up - para.freq_lower) + 0.5*(para.freq_lower + para.freq_up),...
        0.3*(para.freq_up - para.freq_lower) + 0.5*(para.freq_lower + para.freq_up), 20),...
        'color',[255,0,255]/256, 'linewidth',2);
    plot(ax,linspace(sp_cal,sp_cal,20),linspace( -0.3*(para.freq_up - para.freq_lower) + 0.5*(para.freq_lower + para.freq_up),...
        0.3*(para.freq_up - para.freq_lower) + 0.5*(para.freq_lower + para.freq_up), 20),...
        'color',[255,255,240]/256, 'linewidth',2);
end


function [imdata] = readimage(stan,sacdir)
    imname = split(sacdir,'/');
    imagefl = sprintf('%s/%s_%s.png',sacdir,char(imname{end}),char(stan));
    imdata = imread(imagefl);

end

function [sacdata] = readwithseismo(stan,sacdir)
    sacfl = sprintf('%s/*%s*.sac',sacdir,char(stan));
    sacdata = readseizmo(sacfl);
    conpon = zeros(3,1);
    for i = 1:1:3
        if ( ~isempty(strfind(sacdata(i).name, 'BHE')) )
            conpon(i) = 1;
        end
        if ( ~isempty(strfind(sacdata(i).name, 'BHN')) )
            conpon(i) = 1;
        end
        if ( ~isempty(strfind(sacdata(i).name, 'BH1')) )
            conpon(i) = 1;
        end
        if ( ~isempty(strfind(sacdata(i).name, 'BH2')) )
            conpon(i) = 1;
        end
        if ( ~isempty(strfind(sacdata(i).name, 'HH1')) )
            conpon(i) = 1;
        end
        if ( ~isempty(strfind(sacdata(i).name, 'HH2')) )
            conpon(i) = 1;
        end
    end
    ind = find(conpon);
    rotatedsac = rotate([sacdata(ind(1));sacdata(ind(2))],'kcmpnm1','R','kcmpnm2','T');
    sacdata(ind) = rotatedsac(ind);
    sacdata = sortbyfield(sacdata,'dist','ascend');    
end
%% pick functions
    function Pick_callback_pick(h, dummy)
        uicontrol(handle.h_hot);
        disp('Left mouse button picks points.');
        disp('Right mouse button picks last points.');
        para.ypick = [];
        para.xpick = []; 
        para.cordi = {};
        n = 0;
        but = 1;
        xy = zeros(2,2);
        while but == 1
            [xi, yi, but] = myginput(1,'crosshair');
            ci = get(gca,'position');
            plot(xi,yi,'wo','markersize',5,'markerfacecolor','black');
            n = n+1;
            if n > 2
                disp('More than 2 picks selected!')
                break;  
            end
            xy(:,n) = [xi;yi];
            c{n} = ci;
            fprintf('x = %f, y = %f\n',xi,yi);
        end
        para.xpick = xy(1,:);
        para.ypick = xy(2,:);
        para.codi = c;
        if ( length(para.xpick) > 2 || length(para.ypick) > 2 )
            disp('More than 2 picks selected! Please check the code')
            return;
        end
        Pick_save_sac();
    end

    function Pick_callback_reset(h,dummy)
        uicontrol(handle.h_hot);
        para.ypick = [];
        para.xpick = [];
        Pick_callback_replot_1(h, dummy);
        Pick_callback_replot_2(h, dummy);
        Pick_callback_replot_3(h, dummy);
        Pick_callback_replot_4(h, dummy);
        
    end
    function Pick_callback_delete(h, dummy)
        uicontrol(handle.h_hot);
        disp('Left mouse button picks points.');
        disp('Right mouse button picks last points.');
        para.ypick = [];
        para.xpick = []; 
        para.cordi = {};
        n = 0;
        but = 1;
        xy = zeros(2,2);
        while but == 1
            [xi, yi, but] = myginput(1,'crosshair');
            ci = get(gca,'position');
            plot(xi,yi,'wo','markersize',5,'markerfacecolor','black');
            n = n+1;
            if n > 2
                disp('More than 2 picks selected!')
                break;  
            end
            xy(:,n) = [xi;yi];
            c{n} = ci;
            fprintf('x = %f, y = %f\n',xi,yi);
        end
        para.xpick = xy(1,:);
        para.ypick = xy(2,:);
        para.codi = c;
        if ( length(para.xpick) > 2 || length(para.ypick) > 2 )
            disp('More than 2 picks selected! Please check the code')
            return;
        end
        [~,m] = size(para.xpick);
        [~,n] = size(para.ypick);
        if ( m ~= 2 || n ~= 2)
            disp('no pick was made or more than 2 picks are made!');
            return;
        end
        disp('The phase selected (P or S) will be deleted and save in DeletePS dir!');
        para.xpick(:) = -10;
        para.ypick(:) = -10;
        % find the position for the four axes handle.hax{i}
        num_handle = 4;
        codr = zeros(4,4);       
        for i = 1:1:num_handle
            codr(i,:) = get(handle.hax{i},'position');
            codr(i,3) = codr(i,1) + codr(i,3);
            codr(i,4) = codr(i,2) + codr(i,4);
        end
        % find on which axes the pick is made for the seismogram
        x_pick = zeros(2,1);
        for i = 1:1:m
            pick_ax = para.codi{i};
            pick_ax(3) = pick_ax(1) + pick_ax(3);
            pick_ax(4) = pick_ax(2) + pick_ax(4);
            for j = 1:1:num_handle
                if ( ( pick_ax(1) > codr(1,1) ) && ( pick_ax(2) > codr(1,2) ) && ( pick_ax(3) < codr(1,3) ) && ( pick_ax(4) < codr(1,4) ) )
                    x_pick(i) = 1;
                elseif ( ( pick_ax(1) > codr(2,1) ) && ( pick_ax(2) > codr(2,2) ) && ( pick_ax(3) < codr(2,3) ) && ( pick_ax(4) < codr(2,4) ) )
                    x_pick(i) = 2;
                elseif ( ( pick_ax(1) > codr(3,1) ) && ( pick_ax(2) > codr(3,2) ) && ( pick_ax(3) < codr(3,3) ) && ( pick_ax(4) < codr(3,4) ) )
                    x_pick(i) = 3;
                elseif ( ( pick_ax(1) > codr(4,1) ) && ( pick_ax(2) > codr(4,2) ) && ( pick_ax(3) < codr(4,3) ) && ( pick_ax(4) < codr(4,4) ) )
                    x_pick(i) = 4;
                end
            end     
        end
        % write into file 
        if x_pick(1) ~= x_pick(2)
            disp('The two points are picked on the different axes! ');
            return;
        else
            ax_number = x_pick(1);
        end
        % if the marked P or S phase is -10 then it means the picked phase
        % must be deleted from the original pick
        if strcmp(para.phase,'P')         
            sacdata = para.sacdata{ax_number};
            for j = 1:1:3
                sacdata(j).head(16) = para.xpick(1);
            end
            writeintosac(sacdata);
       end
       if strcmp(para.phase,'S')          
            sacdata = para.sacdata{ax_number};
            for j = 1:1:3
                sacdata(j).head(16) = para.xpick(1);
            end
            writeintosac(sacdata);
       end
        
    end
    function Pick_save_sac()
        [~,m] = size(para.xpick);
        [~,n] = size(para.codi);
        if ( m ~= 2 || n ~=2 )
            disp('no pick was made or more than 2 picks are made!');
            return;
        end
        % find the position for the four axes handle.hax{i}
        num_handle = 4;
        codr = zeros(4,4);       
        for i = 1:1:num_handle
            codr(i,:) = get(handle.hax{i},'position');
            codr(i,3) = codr(i,1) + codr(i,3);
            codr(i,4) = codr(i,2) + codr(i,4);
        end
        % find on which axes the pick is made for the seismogram
        x_pick = zeros(2,1);
        for i = 1:1:m
            pick_ax = para.codi{i};
            pick_ax(3) = pick_ax(1) + pick_ax(3);
            pick_ax(4) = pick_ax(2) + pick_ax(4);
            for j = 1:1:num_handle
                if ( ( pick_ax(1) > codr(1,1) ) && ( pick_ax(2) > codr(1,2) ) && ( pick_ax(3) < codr(1,3) ) && ( pick_ax(4) < codr(1,4) ) )
                    x_pick(i) = 1;
                elseif ( ( pick_ax(1) > codr(2,1) ) && ( pick_ax(2) > codr(2,2) ) && ( pick_ax(3) < codr(2,3) ) && ( pick_ax(4) < codr(2,4) ) )
                    x_pick(i) = 2;
                elseif ( ( pick_ax(1) > codr(3,1) ) && ( pick_ax(2) > codr(3,2) ) && ( pick_ax(3) < codr(3,3) ) && ( pick_ax(4) < codr(3,4) ) )
                    x_pick(i) = 3;
                elseif ( ( pick_ax(1) > codr(4,1) ) && ( pick_ax(2) > codr(4,2) ) && ( pick_ax(3) < codr(4,3) ) && ( pick_ax(4) < codr(4,4) ) )
                    x_pick(i) = 4;
                end
            end     
        end
        % write into file 
        if x_pick(1) ~= x_pick(2)
            disp('The two points are picked on the different axes! ');
            return;
        else
            ax_number = x_pick(1);
        end
       if strcmp(para.phase,'PS')
           if ( (para.xpick(1) > 0) && (para.xpick(2) > 0 ))
               sacdata = para.sacdata{ax_number};
               for j = 1:1:3
                   sacdata(j).head(14) = para.xpick(1);
                   sacdata(j).head(44) = (para.ypick(1) + para.ypick(2))/2;
                   sacdata(j).head(45) = 0.5*abs(para.xpick(1) - para.xpick(2));
               end
               writeintosac(sacdata);
           end
       end
       if strcmp(para.phase,'SP') 
           if ( (para.xpick(1) > 0) && (para.xpick(2) > 0 ) )
                sacdata = para.sacdata{ax_number};
                for j = 1:1:3
                    sacdata(j).head(14) = para.xpick(1);
                    sacdata(j).head(44) = (para.ypick(1) + para.ypick(2))/2;
                    sacdata(j).head(45) = 0.5*abs(para.xpick(1) - para.xpick(2));
                end
                writeintosac(sacdata);
           end
       end
       if strcmp(para.phase,'Guided P') 
           if ( (para.xpick(1) > 30) && (para.xpick(2) > 30 ))
                sacdata = para.sacdata{ax_number};
                for j = 1:1:3
                    sacdata(j).head(15) = para.xpick(1);
                    sacdata(j).head(44) = (para.ypick(1) + para.ypick(2))/2;
                end
                writeintosac(sacdata);
           end
       end
       if strcmp(para.phase,'P')
           if ( (para.xpick(1) > -5 ) && (para.xpick(2) > -5 ))
                sacdata = para.sacdata{ax_number};
                for j = 1:1:3
                    sacdata(j).head(16) = para.xpick(1);
                    sacdata(j).head(44) = (para.ypick(1) + para.ypick(2))/2;
                    sacdata(j).head(45) = 0.5*abs(para.xpick(1) - para.xpick(2));
                end
                writeintosac(sacdata);
           end
       end
       if strcmp(para.phase,'S')
           if ( (para.xpick(1) > -5 ) && (para.xpick(2) > -5 ))
                sacdata = para.sacdata{ax_number};
                for j = 1:1:3
                    sacdata(j).head(16) = para.xpick(1);
                    sacdata(j).head(44) = (para.ypick(1) + para.ypick(2))/2;
                    sacdata(j).head(45) = 0.5*abs(para.xpick(1) - para.xpick(2));
                end
                writeintosac(sacdata);
           end
       end
    end

    function Pick_callback_save_figure(h,dummy)
        uicontrol(handle.h_hot);
        set(gcf,'PaperPositionMode','auto');
        if strcmp(para.phase,'PS') 
            %% write the picked phase into the sac files the PS converted phase time is
            % stored in T3, and the corresponding frequency is stored in user3
            %% the picking error is calculated as the range of half the length between
            % para.xpick(i) and para.xpick(i+1), however the onset of the
            % phase is set as para.xpick(i). The error is stored in user4.
            % If the picked phase is marked as less than 0s, then it means
            % there is no PS phase
%             for i = 1:2:7
%                 if ( (para.xpick(i) > 0) && (para.xpick(i+1) > 0 ))
%                     if ( i == 1 )
%                         sacdata = para.sacdata{1};
%                         for j = 1:1:3
%                             sacdata(j).head(14) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 3 )
%                         sacdata = para.sacdata{2};
%                         for j = 1:1:3
%                             sacdata(j).head(14) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 5 )
%                         sacdata = para.sacdata{3};
%                         for j = 1:1:3
%                             sacdata(j).head(14) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 7 )
%                         sacdata = para.sacdata{4};
%                         for j = 1:1:3
%                             sacdata(j).head(14) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     end
%                 end
%             end
            % save the figure no matter if there is a PS, SP or guided P
            % detected
            if (para.istation < para.istanumber - 3)
                figname = sprintf('%s/%s_%s_%s~%s_PS',para.figure_PSdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istation + 3}));
                disp('PS Figure for the plot saved!');
            else
                figname = sprintf('%s/%s_%s_%s~%s_PS',para.figure_PSdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istanumber}));
                disp('PS Figure for the plot saved!');
            end
            print(figname, '-dpng', '-r300');
%           
        end
        if strcmp(para.phase,'SP') 
%             for i = 1:2:7
%                 if ( (para.xpick(i) > 0) && (para.xpick(i+1) > 0 ))
%                     if ( i == 1 )
%                         sacdata = para.sacdata{1};
%                         for j = 1:1:3
%                             sacdata(j).head(14) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 3 )
%                         sacdata = para.sacdata{2};
%                         for j = 1:1:3
%                             sacdata(j).head(14) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 5 )
%                         sacdata = para.sacdata{3};
%                         for j = 1:1:3
%                             sacdata(j).head(14) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 7 )
%                         sacdata = para.sacdata{4};
%                         for j = 1:1:3
%                             sacdata(j).head(14) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     end
%                 end
%             end
            % save the figure no matter if there is a PS, SP or guided P
            % detected
            if (para.istation < para.istanumber - 3)
                figname = sprintf('%s/%s_%s_%s~%s_SP',para.figure_SPdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istation + 3}));
                disp('SP Figure for the plot saved!');
            else
                figname = sprintf('%s/%s_%s_%s~%s_SP',para.figure_SPdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istanumber}));
                disp('SP Figure for the plot saved!');
            end
            print(figname, '-dpng', '-r300');
        end
        if strcmp(para.phase,'Guided P') 
%             for i = 1:2:7
%                 if ( (para.xpick(i) > 30) && (para.xpick(i+1) > 30 ))
%                     if ( i == 1 )
%                         sacdata = para.sacdata{1};
%                         for j = 1:1:3
%                             sacdata(j).head(15) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 3 )
%                         sacdata = para.sacdata{2};
%                         for j = 1:1:3
%                             sacdata(j).head(15) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 5 )
%                         sacdata = para.sacdata{3};
%                         for j = 1:1:3
%                             sacdata(j).head(15) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 7 )
%                         sacdata = para.sacdata{4};
%                         for j = 1:1:3
%                             sacdata(j).head(15) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                         end
%                         writeintosac(sacdata);
%                     end
%                 end
%             end
            % save the figure no matter if there is a PS, SP or guided P
            % detected
            if (para.istation < para.istanumber - 3)
                figname = sprintf('%s/%s_%s_%s~%s_Guided_P',para.figure_GuidedPdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istation + 3}));
                disp('Guided P Figure for the plot saved!');
            else
                figname = sprintf('%s/%s_%s_%s~%s_Guided_P',para.figure_GuidedPdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istanumber}));
                disp('Guided P Figure for the plot saved!');
            end
            print(figname, '-dpng', '-r300');
        end
        if strcmp(para.phase,'P')
%             for i = 1:2:7
%                 if ( (para.xpick(i) > -5 ) && (para.xpick(i+1) > -5 ))
%                     if ( i == 1 )
%                         sacdata = para.sacdata{1};
%                         for j = 1:1:3
%                             sacdata(j).head(16) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 3 )
%                         sacdata = para.sacdata{2};
%                         for j = 1:1:3
%                             sacdata(j).head(16) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 5 )
%                         sacdata = para.sacdata{3};
%                         for j = 1:1:3
%                             sacdata(j).head(16) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 7 )
%                         sacdata = para.sacdata{4};
%                         for j = 1:1:3
%                             sacdata(j).head(16) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     end
%                 end
%             end
            % save the figure no matter if there is a PS, SP or guided P
            % detected
            if (para.istation < para.istanumber - 3)
                figname = sprintf('%s/%s_%s_%s~%s_P',para.figure_ChangePdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istation + 3}));
                disp('P Figure for the plot saved!');
            else
                figname = sprintf('%s/%s_%s_%s~%s_P',para.figure_ChangePdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istanumber}));
                disp('P Figure for the plot saved!');
            end
            print(figname, '-dpng', '-r300');
        end
        if strcmp(para.phase,'S')
%             for i = 1:2:7
%                 if ( (para.xpick(i) > -5 ) && (para.xpick(i+1) > -5 ))
%                     if ( i == 1 )
%                         sacdata = para.sacdata{1};
%                         for j = 1:1:3
%                             sacdata(j).head(16) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 3 )
%                         sacdata = para.sacdata{2};
%                         for j = 1:1:3
%                             sacdata(j).head(16) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 5 )
%                         sacdata = para.sacdata{3};
%                         for j = 1:1:3
%                             sacdata(j).head(16) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     elseif ( i == 7 )
%                         sacdata = para.sacdata{4};
%                         for j = 1:1:3
%                             sacdata(j).head(16) = para.xpick(i);
%                             sacdata(j).head(44) = (para.ypick(i) + para.ypick(i+1))/2;
%                             sacdata(j).head(45) = 0.5*abs(para.xpick(i) - para.xpick(i+1));
%                         end
%                         writeintosac(sacdata);
%                     end
%                 end
%             end
            % save the figure no matter if there is a PS, SP or guided P
            % detected
            if (para.istation < para.istanumber - 3)
                 figname = sprintf('%s/%s_%s_%s~%s_S',para.figure_ChangeSdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istation + 3}));
                 disp('S Figure for the plot saved!');
            else
                figname = sprintf('%s/%s_%s_%s~%s_S',para.figure_ChangeSdir,para.data,char(para.events{para.ievent,1}),char(para.ieve_sta{para.istation}),char(para.ieve_sta{para.istanumber}));
                disp('S Figure for the plot saved!');
            end
            print(figname, '-dpng', '-r300');
        end
    end

    function writeintosac(sacdata)
        if strcmp(char(para.phase), 'PS')
            phasedir = para.PSdir;
        elseif strcmp(char(para.phase), 'SP')
            phasedir = para.SPdir;
        elseif strcmp(char(para.phase), 'Guided P')
            phasedir = para.PreGuidedPdir;
        elseif strcmp(char(para.phase), 'P')
            phasedir = para.ChangePdir;
        elseif strcmp(char(para.phase), 'S')
            phasedir = para.ChangeSdir;
        end
        sta_ini = {sacdata.name};
        sta_temp = split(sta_ini(1),'.');
        sta_temp2 = split(sta_temp(1),'_');
        event_name = sprintf('%s_%s',char(sta_temp2(1)),char(sta_temp2(2)));
        outsacdir = sprintf('%s/%s/%s',phasedir,para.data,event_name);
        if ( exist(outsacdir,'dir') == 0 )
            mkdir(outsacdir);
        end
        for j = 1:1:3
            writeseizmo(sacdata(j),'path',outsacdir);
        end
    end

    function Pick_callback_preevent(h, dummy)
        uicontrol(handle.h_hot);
        if ~isfield(para,'ievent')
            return;
        else
            if ( para.ievent == 1)
                disp('No previous event exist! Already the fist event!')
                return;
            else
                para.ievent = para.ievent - 1;
                para.istation = 1;
                Pick_callback_plot_initial(h, dummy);
            end
        end
    end

    function Pick_callback_nextevent(h, dummy)
        uicontrol(handle.h_hot);
        if ~isfield(para,'ievent')
            return;
        else
            if ( para.ievent == para.nevent )
                disp( ' Already the last event for this dataset!' )
                return;
            else
                para.ievent = para.ievent + 1;
                para.istation = 1;
                Pick_callback_plot_initial(h, dummy);
            end
        end
    end

    function Pick_callback_prestation(h, dummy)
        uicontrol(handle.h_hot);
        if ~isfield(para, 'istation')
            return;
        else
            if ( para.istation < 4 )
                disp( 'No previous station exist! Already the first station!' )
                return;
            else
                para.istation = para.istation - 4;
                Pick_callback_plot_initial(h, dummy);
            end
        end

    end

    function Pick_callback_nextstation(h, dummy)
        uicontrol(handle.h_hot);
        % save the previous plotting information
        idx_istation = para.istation;
        idx_ievent = para.ievent;
        save('recentplot.mat','idx_istation','idx_ievent');
        if ~isfield(para,'istation')
            return;
        else
            if (para.istation <= para.istanumber - 4 )
                para.istation = para.istation + 4;
                Pick_callback_plot_initial(h, dummy);
            else
                disp( 'Already the last four stations for this event! ')
            end
        end
    end

    function Pick_callback_firststation(h, dummy)
        uicontrol(handle.h_hot);
        if ~isfield(para, 'istation')
            return;
        else
            para.istation = 1;
            Pick_callback_plot_initial(h, dummy);
        end
    end

    function Pick_callback_laststation(h, dummy)
        uicontrol(handle.h_hot);
        if ~isfield(para, 'istation')
            return;
        else
            if mod(para.istanumber,4) == 0
                para.istation = para.istanumber - 3;
            else
                para.istation = para.istanumber - mod(para.istanumber,4) + 1;
            end
            Pick_callback_plot_initial(h, dummy);
        end

    end

%% Hot keys
    function Pick_short_cut(src, evnt)
        uicontrol(handle.h_hot);
        if strcmp(evnt.Key,'l')
            Pick_callback_loaddata(src, evnt);
        elseif strcmp(evnt.Key,'i')
            Pick_callback_plot_initial(src, evnt);
        elseif strcmp(evnt.Key,'b')
            Pick_callback_preevent(src, evnt);
        elseif strcmp(evnt.Key,'n')
            Pick_callback_nextevent(src, evnt);
        elseif strcmp(evnt.Key,'comma')
            Pick_callback_prestation(src, evnt);
        elseif strcmp(evnt.Key,'period')
            Pick_callback_nextstation(src, evnt);
        elseif strcmp(evnt.Key,'1')
            Pick_callback_replot_1(src, evnt);
        elseif strcmp(evnt.Key,'2')
            Pick_callback_replot_2(src, evnt);
        elseif strcmp(evnt.Key,'3')
            Pick_callback_replot_3(src, evnt);
        elseif strcmp(evnt.Key,'4')
            Pick_callback_replot_4(src, evnt);
        elseif strcmp(evnt.Key,'p')
            Pick_callback_pick(src, evnt);
        elseif strcmp(evnt.Key,'s')
            Pick_callback_save_figure(src, evnt);
        elseif strcmp(evnt.Key,'r')
            Pick_callback_reset(src, evnt);
        elseif strcmp(evnt.Key,'d')
            Pick_callback_delete(src, evnt);
        end


    end



end
