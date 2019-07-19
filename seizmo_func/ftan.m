function [x_save,fc_save]=ftan(data,res,flag,xi,fci,freq_ini,h1,h2,varargin)
%FTAN    FTAN style plotting of SEIZMO data
%
%    Usage:    ftan(data)
%              ftan(data,alpha)
%              ftan(...,'numfreq',nfreq,...)
%              ftan(...,'freqrange',frange,...)
%              ftan(...,'postfunc',func,...)
%              ftan(...,'zlim',zlim,...)
%              ftan(...,'zcolormap',cmap,...)
%              ftan(...,'axis',handle,...)
%              ftan(...,'option',value,...)
%              data=ftan(...)
%
%    Description:
%     FTAN(DATA) plots records in SEIZMO struct DATA as the timeseries
%     above a spectrogram (for easy visual comparison).  Multiple records
%     are plotted in a series of subplots.  All records must be evenly
%     sampled time series records.  The spectrogram plot is generated by
%     implementing a cascade of frequency-domain gaussian filters.  The
%     plots are drawn in a new figure window.
%
%     FTAN(DATA,ALPHA) adjusts a parameter controlling the frequency vs
%     time resolution.  Higher A gives better frequency resolution while
%     lower A gives better time resolution.  The default value of ALPHA is
%     100 and provides a decent balance between resolutions.  See
%     OMEGAGAUSSIAN for further details.
%
%     FTAN(...,'NUMFREQ',NFREQ,...) sets the number of center frequencies
%     (and thus gaussian filters) for each record.  The default is 100.
%     Setting NFREQ too low can limit the frequency resolution.
%
%     FTAN(...,'FREQRANGE',FRANGE,...) specifies the frequency range
%     to plot in the spectrogram.  The default FRANGE is [0 Fnyquist].
%     FRANGE must be [FREQLOW FREQHIGH].
%
%     FTAN(...,'POSTFUNC',FUNC,...) applies FUNC to the analytic signals
%     created.  The default is @abs.  Another possibility is @angle.
%
%     FTAN(...,'ZLIM',ZLIM,...) rescales the colormap to extend to the
%     ranges in ZLIM.  ZLIM should be given as [AMPLO AMPHI].  The default
%     extends across the whole range.
%
%     FTAN(...,'ZCOLORMAP',CMAP,...) alters the colormap used in the
%     spectrogram plots.  The default colormap is FIRE.  The colormap may
%     be a Nx3 RGB triplet array or a string that may be evaluated to a Nx3
%     RGB triplet.
%
%     FTAN(...,'AXIS',HANDLE,...) plots the entire set of spectrograms
%     in the space allocated to HANDLE.  Useful for compiling different
%     information into a single figure.
%
%     FTAN(...,'OPTION',VALUE,...) sets certain plotting options to do
%     simple manipulation of the plots.  Available options are:
%      FGCOLOR    -- foreground color (axes, text, labels)
%      BGCOLOR    -- background color (does not set figure color)
%      COLORMAP   -- colormap for coloring records
%      XLABEL     -- record x axis label
%      YLABEL     -- y axis label
%      TITLE      -- title
%      XLIM       -- record x axis limits (tight by default)
%      YLIM       -- record y axis limits (tight by default)
%      LINEWIDTH  -- line width of records (default is 1)
%      LINESTYLE  -- line style of records (can be char/cellstr array)
%      NUMCOLS    -- number of subplot columns
%      UTC        -- plot in absolute time if TRUE (UTC w/ no leap support)
%      DATEFORMAT -- date format used if ABSOLUTE (default is auto)
%      XDIR       -- 'normal' or 'reverse'
%      YDIR       -- 'normal' or 'reverse'
%      FONTSIZE   -- size of fonts in the axes
%      FONTWEIGHT -- 'light', 'normal', 'demi' or 'bold'
%      MARKERS    -- true/false where true draws the markers
%
%     DATA=FTAN(...) returns with the spectrogram stored as the dependent
%     component data in SEIZMO struct DATA.  This means that the records
%     are of XYZ datatype.  B,E,DELTA,NXSIZE,XMINIMUM,XMAXIMUM provide the
%     timing info while NYSIZE, YMINIMUM, YMAXIMUM provide the frequency
%     info.  NPTS is the number of pixels in the spectrogram.
%
%    Notes:
%
%    Header changes: NPTS, NXSIZE, NYSIZE, IFTYPE,
%                    DEPMEN, DEPMIN, DEPMAX,
%                    XMINIMUM, XMAXIMUM, YMINIMUM, YMAXIMUM
%
%    Examples:
%     % Plot records with spectrograms showing 0-0.02Hz:
%     ftan(data,'fr',[0 0.02]);
%
%     % Plot 4 records in a subplot:
%     h=subplot(3,3,5);
%     ftan(data(1:4),'axis',h);
%
%    See also: SFT, DFT, IDFT, OMEGAGAUSSIAN, OMEGAANALYTIC

%     Version History:
%        Aug.  2, 2012 - initial version
%        Mar.  1, 2014 - maketime fix
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Mar.  1, 2014 at 18:25 GMT

% todo:

% check nargin

error(nargchk(1,inf,nargin));

% check struct
error(seizmocheck(data,'dep'));
nrecs=numel(data);

% turn off struct checking
oldseizmocheckstate=seizmocheck_state(false);

% strip off alpha
if(nargin>=2 && isnumeric(varargin{1}))
    alpha=varargin{1};
    varargin(1)=[];
else
    alpha=res;
end
if(isscalar(alpha)); alpha(1:nrecs,1)=alpha; end

% check alpha
if(~any(numel(alpha)==[1 nrecs]))
    error('seizmo:ftan:badInput',...
        'ALPHA must be scalar or 1 value/record in data!');
elseif(any(alpha<=0))
    error('seizmo:ftan:badInput',...
        'ALPHA must be positive!');
end

% default/parse options
opt=parse_seizmo_plot_options(varargin{:});

% attempt spectrogram
try
    % check headers
%     checkheader(data,...
%         'FALSE_LEVEN','ERROR',...
%         'XYZ_IFTYPE','ERROR');
    
    % verbosity
    verbose=seizmoverbose;
    
    % line coloring
    if(ischar(opt.CMAP) || iscellstr(opt.CMAP))
        % list of color names or a colormap function
        try
            % attempt color name to rgb conversion first
            opt.CMAP=name2rgb(opt.CMAP);
            opt.CMAP=repmat(opt.CMAP,ceil(nrecs/size(opt.CMAP,1)),1);
        catch
            % guess its a colormap function then
            opt.CMAP=str2func(opt.CMAP);
            opt.CMAP=opt.CMAP(nrecs);
        end
    else
        % numeric colormap array
        opt.CMAP=repmat(opt.CMAP,ceil(nrecs/size(opt.CMAP,1)),1);
    end
    
    % line style/width
    opt.LINESTYLE=cellstr(opt.LINESTYLE);
    opt.LINESTYLE=opt.LINESTYLE(:);
    opt.LINESTYLE=repmat(opt.LINESTYLE,...
        ceil(nrecs/size(opt.LINESTYLE,1)),1);
    opt.LINEWIDTH=opt.LINEWIDTH(:);
    opt.LINEWIDTH=repmat(opt.LINEWIDTH,...
        ceil(nrecs/size(opt.LINEWIDTH,1)),1);
    
    % check filetype (only timeseries or xy)
    iftype=getheader(data,'iftype id');
    spec=strcmpi(iftype,'irlim') | strcmpi(iftype,'iamph');
    
    % convert spectral to timeseries
    if(sum(spec)); data(spec)=idft(data(spec)); end
    
    % header info
    % modifoed by Fan Jan 7 2019
    [b,e,npts,delta,ncmp,z6,kname,idep,t1,t2]=getheader(data,...
        'b','e','npts','delta','ncmp','z6','kname','idep desc','t1','t2');
    z6=datenum(cell2mat(z6));
    
    % get markers info
    [marknames,marktimes]=getmarkers(data);
    
    % convert markers to absolute time if used
    if(opt.ABSOLUTE)
        marktimes=marktimes/86400+z6(:,ones(1,size(marktimes,2)));
    end
    
    % check ftan options
    if(~isreal(opt.NUMFREQ) || ~any(numel(opt.NUMFREQ)==[1 nrecs]) ...
            || any(opt.NUMFREQ<=0) ...
            || any(opt.NUMFREQ~=fix(opt.NUMFREQ)))
        error('seizmo:ftan:badInput',...
            'NUMFREQ must be a integer-valued scalar/vector >0!');
    end
    if(isscalar(opt.NUMFREQ)); opt.NUMFREQ(1:nrecs,1)=opt.NUMFREQ; end
    if(~isa(opt.POSTFUNC,'function_handle'))
        error('seizmo:ftan:badInput',...
            'POSTFUNC must be @abs or @angle!');
    end
    if(ischar(opt.ZCMAP))
        opt.ZCMAP=cellstr(opt.ZCMAP);
    end
    if(isreal(opt.ZCMAP) && ndims(opt.ZCMAP)==2 ...
            && size(opt.ZCMAP,2)==3 ...
            && all(opt.ZCMAP(:)>=0 & opt.ZCMAP(:)<=1))
        opt.ZCMAP={opt.ZCMAP};
    elseif(iscellstr(opt.ZCMAP))
        % nothing
    else
        error('seizmo:ftan:badInput',...
            ['DBCOLORMAP must be a colormap function\n'...
            'string or a Nx3 RGB triplet array!']);
    end
    if(isscalar(opt.ZCMAP))
        opt.ZCMAP(1:nrecs,1)=opt.ZCMAP;
    elseif(numel(opt.ZCMAP)~=nrecs)
        error('seizmo:ftan:badInput',...
            ['DBCOLORMAP must be a colormap function\n'...
            'string or a Nx3 RGB triplet array!']);
    end
    % secret option!!!
    if(~isreal(opt.HOTROD) ...
            || ~any(numel(opt.HOTROD)==[1 nrecs]) ...
            || any(opt.HOTROD<0 | opt.HOTROD>1))
        error('seizmo:ftan:badInput',...
            'HOTROD must be between 0 & 1!');
    end
    if(size(opt.HOTROD,1)==1); opt.HOTROD(1:nrecs,1)=opt.HOTROD; end
    if(~isempty(opt.ZRANGE))
        if(~isreal(opt.ZRANGE) || size(opt.ZRANGE,2)~=2 ...
                || ~any(size(opt.ZRANGE,1)==[1 nrecs]) ...
                || any(opt.ZRANGE(:,1)>opt.ZRANGE(:,2)))
            error('seizmo:ftan:badInput',...
                'DBRANGE must be Nx2 array of [DBLOW DBHIGH]!');
        end
        if(size(opt.ZRANGE,1)==1)
            opt.ZRANGE=opt.ZRANGE(ones(nrecs,1),:);
        end
    end
    if(~isempty(opt.FRANGE))
        if(~isreal(opt.FRANGE) || size(opt.FRANGE,2)~=2 ...
                || ~any(size(opt.FRANGE,1)==[1 nrecs]) ...
                || any(opt.FRANGE(:,1)>opt.FRANGE(:,2)) ...
                || any(opt.FRANGE<0))
            error('seizmo:ftan:badInput',...
                'FREQRANGE must be Nx2 array of [FREQLO FREQHI]!');
        end
        if(size(opt.FRANGE,1)==1)
            opt.FRANGE=opt.FRANGE(ones(nrecs,1),:);
        end
    else
        opt.FRANGE=[zeros(nrecs,1) 1./(2*delta)];
    end
    
    % plotting setup
    %if(~nargout)
        % error about plotting multi-cmp records
        if(any(ncmp>1))
            error('seizmo:ftan:noMultiCMPplotting',...
                'FTAN does not support plotting multicmp records!');
        end
        
        % make new figure if invalid or no axes handle passed
%         if(isempty(opt.AXIS) || any(~ishandle(opt.AXIS)) ...
%                 || any(~strcmp('axes',get(opt.AXIS,'type'))))
%             fh=figure('color',opt.BGCOLOR,'name','FTAN -- SEIZMO');
%             opt.AXIS=axes('parent',fh);
%         end
        
        % handle single axis vs multiple axis
%         if(numel(opt.AXIS)==nrecs)
%             % get positioning
%            % drawnow;
%             op=get(opt.AXIS,'position');
% %             fh=get(opt.AXIS,'parent');
%            % delete(opt.AXIS);
%             
%             % uncell (if more than one record)
%             if(iscell(op)); op=cell2mat(op); end
% %             if(iscell(fh)); fh=cell2mat(fh); end
%             
%             % "subplot positioning" aka not really
%             pwidth=op(:,3);
%             height=op(:,4);
%             leftb=op(:,1);
%             bottom=op(:,2);
%         elseif(isscalar(opt.AXIS))
%             % get positioning
%             %drawnow;
%             op=get(opt.AXIS,'position');
%          %   fh=get(opt.AXIS,'parent');
% %             delete(opt.AXIS);
%             
%             % expand figure handle scalar so there is one for each record
%         %    fh=fh(ones(nrecs,1));
%             
%             % number of columns
%             if(isempty(opt.NUMCOLS))
%                 opt.NUMCOLS=round(sqrt(nrecs));
%             end
%             nrows=ceil(nrecs/opt.NUMCOLS);
%             
%             % outer position of each subplot
%             % [left bottom width height]
%             pwidth=op(3)/opt.NUMCOLS;
%             height=op(4)/nrows;
%             leftb = zeros(  round(((op(1)+op(3)-pwidth) - op(1))/pwidth) + 1, 1 );
%             for i = 1:1:length(leftb)
%                 leftb(i) = op(1) + (i-1)*pwidth;
%             end
%             %leftb=op(1):pwidth:(op(1)+op(3)-pwidth);
%             leftb=leftb(ones(nrows,1),:)';
%             bottom=op(2):height:op(2)+op(4)-height;
%             bottom=flipud(bottom(ones(opt.NUMCOLS,1),:)')';
%         else
%             error('seizmo:ftan:badInput',...
%                 'Incorrect number of axes handles in AXIS!');
%         end
%         cla(opt.AXIS,'reset');
%         % plot constants to make text look "right"
%         % ...well as much as we can without changing fontsize
%         sh=0.6;
%         sw=0.9;
%         tpl=min([0.02 (1-sh)*height sh*height sw*pwidth (1-sw)*pwidth]);
%         jt=2/3*tpl;
%         cbw=0.02;
    %end
    
    % detail message
    if(verbose)
        disp('Getting FTAN of Record(s)');
        print_time_left(0,nrecs);
    end
    
    % modified by fan 2019/02/01 
    % normalized data 
    for i = 1:nrecs
        max_dep(i) = max(abs(data(i).dep(:)));
    end
    maxx_dep = max(max_dep);  
    for i = 1:nrecs
        data(i).dep(:) = data(i).dep(:)/max(abs(data(i).dep(:)))*maxx_dep;
    end
%   
    % loop over records
    
    nxsize=npts;
    [nysize,yminimum,ymaximum]=deal(nan(nrecs,1));
    [depmen,depmin,depmax]=deal(nysize);
    %set(gca,'Visible','off');
    for i=1:nrecs
        % skip dataless
        if(~npts(i)); continue; end
        
        % return spectrograms
%         if(nargout)
%             % get spectrogram
%             x=cell(1,ncmp(i));
%             for j=1:ncmp(i)
%                 [x{j},fc]=goftan(double(data(i).dep(:,j)),...
%                     delta(i),alpha(i),opt.FRANGE(i,:),opt.NUMFREQ(i));
%                 x{j}=x{j}(:); % make column vector
%             end
%             
%             % assign power spectra to dep
%             data(i).dep=opt.POSTFUNC(cell2mat(x));
%             
%             % get fields
%             % Differences from SAC (!!!):
%             % - b/e/delta are timing related
%             % - xminimum/xmaximum/yminimum/ymaximum are time/freq values
%             npts(i)=numel(x{1});
%             nysize(i)=numel(fc);
%             yminimum(i)=fc(1);
%             ymaximum(i)=fc(end);
%             depmen(i)=nanmean(data(i).dep(:));
%             depmin(i)=min(data(i).dep(:));
%             depmax(i)=max(data(i).dep(:));
%         else % plotting
            % how this is gonna look
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %        record name        %
            %    +---------------+-+    %
            % amp|  seismogram   |c|    %
            %    +---------------+b|    %
            %  f |               |a|    %
            %  r |  spectrogram  |r|    %
            %  e |               | |    %
            %  q +---------------+-+    %
            %        time (sec)   dB    %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % plot record
          %  figure(fh(i));
            
%             h1=axes(...
%                 'outerposition',[leftb(i) bottom(i)+sh*height ...
%                 sw*pwidth (1-sh)*height],...
%                 'position',[leftb(i)+tpl+0.01 bottom(i)+sh*height ...
%                 sw*pwidth-tpl (1-sh)*height-jt],...
%                 'ydir',opt.YDIR,'xdir',opt.XDIR,'color',opt.BGCOLOR,...
%                 'fontsize',opt.FONTSIZE,'fontweight',opt.FONTWEIGHT,...
%                 'xcolor',opt.FGCOLOR,'ycolor',opt.FGCOLOR);
            %h1.ActivePositionProperty = 'position';
            cla(h1{i},'reset');
            cla(h2{i},'reset');
            hold(h1{i},'on');
           % h1.Visible = 'off';
            if(opt.ABSOLUTE)
%                 xlim(h1,opt.XLIM);
                set(h1{i},'ylim',[min(data(i).dep),max(data(i).dep)]);
                set(h1{i},'SortMethod','childorder','NextPlot','replacechildren');
                rh=plot(h1{i},z6(i)+b(i)/86400+...
                    (0:delta(i)/86400:delta(i)/86400*(npts(i)-1)).',...
                    data(i).dep,...
                    'color',opt.CMAP(i,:),...
                    'linewidth',opt.LINEWIDTH(i),...
                    'linestyle',opt.LINESTYLE{i});   
                
            else
                set(h1{i},'xlim',opt.XLIM);
                set(h1{i},'ylim',[min(data(i).dep),max(data(i).dep)]);
                set(h1{i},'SortMethod','childorder','NextPlot','replacechildren');
                rh=plot(h1{i},b(i)+(0:delta(i):delta(i)*(npts(i)-1)).',...
                    data(i).dep,...
                    'color',opt.CMAP(i,:),...
                    'linewidth',opt.LINEWIDTH(i),...
                    'linestyle',opt.LINESTYLE{i});
            end
%             hold(h1{i},'off');
            
            % let matlab sig proc box handle the psd estimation
            % add by fan to store the spectra for the first
            % calculation,then load it when replotting
             if ( flag == 0 )
                [x,fc]=goftan(double(data(i).dep),delta(i),alpha(i),...
                    opt.FRANGE(i,:),opt.NUMFREQ(i));
                x=opt.POSTFUNC(x);
                x_save{i} = x;
                fc_save{i} = fc;
%                 filename = sprintf('subfigure%d.mat',ind_sta);
%                 save(filename,'x','fc');
             elseif ( flag == 1 )
                 x = xi{i};
                 fc = fci{i};
%                 filename = sprintf('subfigure%d.mat',ind_sta);
%                 cal_sp = load(filename);
%                 x = cal_sp.x;
%                 fc = cal_sp.x;
             end
                
            
            % set userdata to everything but data (cleared)
            data(i).dep=[];
            data(i).ind=[];
            data(i).index=[i 1];
            set(rh,'userdata',data(i));
            
            % tag records
            set(rh,'tag','record');
            
            % extras
            box(h1{i},'on');
            grid(h1{i},'on');
            axis(h1{i},'tight');
            
            % add markers to axis userdata
            % add by fan, set the o to be 0;
            marktimes(:,3) = 0;
            userdata.markers.names=marknames(i,:);
            userdata.markers.times=marktimes(i,:);
            userdata.function='ftan';
            set(h1{i},'userdata',userdata);
%             % change 'o' to 'P' and change 't2' to 'PS'; change 't3' to 'S'
%             userdata.markers.names{3} = 'P';
%             userdata.markers.names{5} = 'PS';
%             userdata.markers.names{6} = 'S';
            % draw markers
            if(opt.MARKERS); drawmarkers(h1{i},varargin{:}); end
            
            % truncate to frequency range
            if(isempty(opt.FRANGE))
                frng=[0 1/(2*delta(i))];
            else
                frng=opt.FRANGE(i,:);
            end
            
            % special normalization
            minx=min(x(:)); maxx=max(x(:));
            %x(x<minx+(maxx-minx)*(1-opt.HOTROD(i)))=minx;
            
            % fix timing
            if(opt.ABSOLUTE)
                T=z6(i)+b(i)/86400+...
                    (0:delta(i)/86400:delta(i)/86400*(npts(i)-1));
            else % relative
                T=b(i)+(0:delta(i):delta(i)*(npts(i)-1));
            end
            
            % deal with zrange
            if(isempty(opt.ZRANGE))
                zrng=[minx maxx];
            else
                zrng=opt.ZRANGE(i,:);
            end
          
            % plot spectrogram ourselves
            
%             h2=axes(...
%                 'outerposition',...
%                 [leftb(i) bottom(i) sw*pwidth sh*height],...
%                 'position',[leftb(i)+tpl+0.01 bottom(i)+tpl ...
%                 sw*pwidth-tpl sh*height-tpl],...
%                 'ydir',opt.FDIR,'xdir',opt.XDIR,'color',opt.BGCOLOR,...
%                 'fontsize',opt.FONTSIZE,'fontweight',opt.FONTWEIGHT,...
%                 'xcolor',opt.FGCOLOR,'ycolor',opt.FGCOLOR);
            set(h2{i},'SortMethod','childorder','NextPlot','replacechildren');
%             xlim(h2,opt.XLIM);
           
            hold(h2{i},'on');
            %h2.Visible = 'off';
            if ( flag == 0 )
                imagesc(T,frng,x.','parent',h2{i},zrng);
                axis(h2{i},'tight');
            elseif ( flag == 1 )
                imagesc(T,freq_ini,x.','parent',h2{i},zrng);
                axis(h2{i},'tight');
                set(h2{i},'ylim',opt.FRANGE(i,:));
            end
            % changed option by Fan Jan 8 2019
%             hold(h2,'off');
           % hold(h2,'on');
            

            % extras
            %ylabel(h2,'Freq (Hz)');
            colormap(h2{i},opt.ZCMAP{i});
            set(gca,'ColorScale','log')
            %axis(h2{i},'xy','tight');
            axis(h2{i},'xy');
           
            grid(h2{i},'on');
            
            % axis zooming
            if(~isempty(opt.XLIM)); xlim(h2{i},opt.XLIM); end
            if(~isempty(opt.YLIM)); ylim(h1{i},opt.YLIM); end
            
            % sync times of timeseries and spectrogram
            set(h1{i},'xlim',get(h2{i},'xlim'));
            
            % do the datetick thing
            if(opt.ABSOLUTE)
                if(isempty(opt.DATEFORMAT))
                    if(isempty(opt.XLIM))
                        datetick(h1{i},'x');
                        datetick(h2{i},'x');
                    else
                        datetick(h1{i},'x','keeplimits');
                        datetick(h2{i},'x','keeplimits');
                    end
                else
                    if(isempty(opt.XLIM))
                        datetick(h1{i},'x',opt.DATEFORMAT);
                        datetick(h2{i},'x',opt.DATEFORMAT);
                    else
                        datetick(h1{i},'x',opt.DATEFORMAT,'keeplimits');
                        datetick(h2{i},'x',opt.DATEFORMAT,'keeplimits');
                    end
                end
            else
                if(~isempty(opt.DATEFORMAT))
                    if(isempty(opt.XLIM))
                        datetick(h1{i},'x',opt.DATEFORMAT);
                        datetick(h2{i},'x',opt.DATEFORMAT);
                    else
                        datetick(h1{i},'x',opt.DATEFORMAT,'keeplimits');
                        datetick(h2{i},'x',opt.DATEFORMAT,'keeplimits');
                    end
                end
            end
            
            % turn off tick labels on timeseries
            set(h1{i},'xticklabel',[]);
%             set(h2{i},'XTickLabel',['0.5', '2', '4', '6', '8', '10', '12']);
           % h2{i}.YTick = [0.5 2 4 6 8 10 12];
           % h2{i}.XTick = [-5 0 5 10 20 30 40 50 60 70 80 90];
            %xticks(h2{i}, [-5 0 5 10 15 20 30 40 50 60 70]);
%             set(gca,'Xtick',-5:15:75);
            % add by fan
%             set(h1{i},'yticklabel',[]);
           % set(h2{i},'xticklabel',[]);
%             set(h2,'ylim',opt.FRANGE(i,:));
            % set(h2{i},'yticklabel',[]);

            % now lets link the x axes together
%             linkaxes([h1 h2],'x');
            
            % label
            if(~isempty(opt.TITLE) && isnumeric(opt.TITLE))
                switch opt.TITLE
                    case 1 % filename
                        if(~isempty(data(i).name))
                            p1title=texlabel(data(i).name,'literal');
                        else
                            p1title=['RECORD ' num2str(i)];
                        end
                    case 2 % kstnm
                        p1title=kname(i,2);
                    case 3 % kcmpnm
                        p1title=kname(i,4);
                    case 4 % shortcmp
                        p1title=kname{i,4}(3);
                    case 5 % stashort
                        p1title=strcat(kname(i,2),'.',kname{i,4}(3));
                    case 6 % stcmp
                        p1title=strcat(kname(i,2),'.',kname(i,4));
                    case 7 % kname
                        p1title=texlabel(strcat(kname(i,1),...
                            '.',kname(i,2),'.',kname(i,3),...
                            '.',kname(i,4)),'literal');
                    otherwise
                        p1title=['RECORD ' num2str(i)];
                end
            else
                p1title=opt.TITLE;
            end
            if(isnumeric(opt.XLABEL) && opt.XLABEL==1)
                if(opt.ABSOLUTE)
                    xlimits=get(h1{i},'xlim');
                    p1xlabel=joinwords(...
                        cellstr(datestr(unique(fix(xlimits)))),'   to   ');
                else
                    p1xlabel='Time (sec)';
                end
            else
                p1xlabel=opt.XLABEL;
            end
%             if(isnumeric(opt.YLABEL) && opt.YLABEL==1)
%                 p1ylabel=idep(i);
%             else
%                 p1ylabel=opt.YLABEL;
%             end
            if (i == 1)
%                  title(h1{i},p1title,'color',opt.FGCOLOR,...
%                      'fontsize',opt.FONTSIZE,'fontweight',opt.FONTWEIGHT);
             %  titlename = split(data(i).name,'.');
               %set(h1{i},'Title.String',char(titlename{1}));
               h1{i}.Title.String = p1title;
            end
%             xlabel(h2,p1xlabel,'color',opt.FGCOLOR,...
%                 'fontsize',opt.FONTSIZE,'fontweight',opt.FONTWEIGHT);
%             ylabel(h1,p1ylabel,'color',opt.FGCOLOR,...
%                 'fontsize',opt.FONTSIZE,'fontweight',opt.FONTWEIGHT);
            
            % plot colorbar
            % entire height
            % 25% of width
            
%             c=colorbar('peer',h2,'position',...
%                 [leftb(i)+sw*pwidth+0.01 bottom(i)+tpl ...
%                 cbw*pwidth height-tpl-jt]);
%             ylim(c,opt.ZRANGE(i,:));
%             %xlabel(c,'dB');
%             set(c,'xcolor',opt.FGCOLOR,'ycolor',opt.FGCOLOR);
%             set(get(c,'XLabel'),'color',opt.FGCOLOR);
            
%         end
        
        %h1.Visible = 'on';
        %h2.Visible = 'on';
        % detail message
        if(verbose); print_time_left(i,nrecs); end
    end
   % drawnow;
   % set(gca,'Visible','on');
    % update headers if there is output args
    if(nargout)
        varargout{1}=changeheader(data,'npts',npts,'iftype','ixyz',...
            'nxsize',nxsize,'nysize',nysize,...
            'depmen',depmen,'depmin',depmin,'depmax',depmax,...
            'xminimum',b,'xmaximum',e,...
            'yminimum',yminimum,'ymaximum',ymaximum);
    end
    
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
    
catch
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
    
    % rethrow error
    error(lasterror);
end
%     % added by Fan Jan 8 2019, make the figure larger
%     posi = get(gcf,'position');
%     posi = [posi(1:2),2*posi(3:4)];
%     set(gcf,'position',posi);
%     % ginput to get the position of the picked phases
%     % pick the most beginer of the phase
%     [timep, frqp] = ginput(1);
%     fprintf('%f,%f\n',timep,frqp);
%     % pick the last onset of the phase
%     [timen, frqn] = ginput(1);
%     fprintf('%f,%f\n',timen,frqn);
%     %hold(h2,'on');
%     frange = unique(opt.FRANGE);
%     plot(linspace(timep,timep,20),linspace(frange(1),frange(2),20),'color','w','linewidth',2);
%     hold(h2,'on');
    
end


function [x,fc]=goftan(x,delta,alpha,frng,nf)
npts=numel(x);
nfpts=2^nextpow2(npts);
nfpts2=nfpts/2;
fnyq=1/(2*delta);
fdelta=2*fnyq/nfpts;
f=[0:fdelta:fdelta*nfpts2 fdelta*(nfpts2-1):-fdelta:fdelta].';
if(isempty(frng)); frng=[0 fnyq]; end
fcstep=diff(frng)/nf;
fc=frng(1)+fcstep/2:fcstep:frng(2)-fcstep/2;
x=delta*fft(x,nfpts,1);
x=x(:,ones(1,nf));
for i=1:nf; x(:,i)=x(:,i).*exp(-alpha*((f-fc(i))/fc(i)).^2); end
x(2:nfpts2,:)=2*x(2:nfpts2,:);
x(nfpts2+2:end,:)=0;
x=ifft(x,[],1);
x=x(1:npts,:);
end
