% impplot.m
%
% implot(imp)
%
% GUI is created with a Callback event-driven interface, handled via a
% SwitchYard, all through this single file.
%
% imp is an impedance structure, as returned by NECRead.m or NECReadZin.m,
% with two members: freq (nFx1) frequencies in MHz, and impedance (nFx1)
% complex impedances in Ohms.
%
% impplot plots the impedances, normalised to 50 Ohms on a Smith Chart
% initially. Various other possibilities exist from the GUI.
%


function impplot(imp)
% -------------------------------------------------------------------------
% Default plot on Smith, Z0=50 Ohms.
% -------------------------------------------------------------------------

  CFh = get(0, 'CurrentFigure');
  CBh = get(0, 'CallBackObject');

  if isempty(CFh)
    if ((nargin==1) && isstruct(imp))
      CFh = impplotCreate(imp);
    else 
      error(['impplot(imp); imp is a structure with ',...
             'freq and complex impedance vectors']);
    endif
  endif

  if isempty(CBh)
    return;
  endif

  % Figure exists, with a CallBack:
  CBTag = lower(get(CBh, 'Tag'));

  % Actual SwitchYard...
  switch CBTag
    case {'format.smith_chart', 'format.magnitude/phase',...
        'format.real/imaginary', 'format.vswr',...
        'format.reflection_coefficient'}
      % Clear all previous checks
      pa = get(CBh, 'parent');
      chld = get(pa, 'children');
      set(chld, 'Checked', 'Off');
      set(CBh, 'Checked', 'On');
      impplotUpdate(CFh);

    case 'impline'
      typ = get(CFh, 'SelectionType');
      if strcmpi(typ, 'normal')
        msgbox('left');
      elseif strcmpi(typ, 'alt')
        msgbox('right');
      endif
      % Each line can be added, no reason for 6 predone etc.
      % Right button: line colour, solid/dotted/marker, linewidth, legend for 'legends'
      % Left Button: marker for 'markers' in markerAx.

    case 'help.about'
      helpdlg(...
        {'Impedance Plotter',...
        'Part of ArcNEC','',...
        'Plots impedances on Smith Charts',...
        'Magnitude/Phase; Real/Imaginary',...
        'VSWR, Reflection Coefficient',...
        '', 'AlanRobertClark@gmail.com 20180521'}...
        , 'About impplot()');
  endswitch
endfunction

function CFh = impplotCreate(imp)
% -------------------------------------------------------------------------
% Creates the Impedance Plotter GUI, and stores the data in the figure
% UserData.
% -------------------------------------------------------------------------

  CFh = figure('Name', 'Impedance Plotter',...
               'NumberTitle', 'Off');
  % Octave Bug 53307 'MenuBar', 'None' %$#!@
  ud = get(CFh, 'UserData');
  % Store position, to use figreset() for the bug.
  ud.pos = get(CFh, 'Position');
  ud.Zo = 50; % default.
  ud.dataAx = axes('Visible', 'Off');
  ud.dataAx2 = axes('Visible', 'Off');
  ud.legendAx = axes('Visible', 'Off');
  ud.markerAx = axes('Visible', 'Off', 'Tag', 'MarkersAxes',...
    'Box', 'On');
  set(CFh, 'CurrentAxes', ud.dataAx);

  % File Save for printEpsPng...

  menu = {'&Format', '>&Smith_Chart', '>&Magnitude/Phase',...
          '>&Real/Imaginary', '>----', '>&VSWR',...
          '>Re&flection_Coefficient'};
  ud.handles.menu = arcmakemenu(CFh, 'impplot;', menu);
  set(ud.handles.menu(2), 'Checked','On'); % Smith
  ud.handles.stored.formats = ud.handles.menu(2:end);

  menu = {'&Help', '>&About'};
  handles = arcmakemenu(CFh, 'impplot;', menu);
  ud.handles.menu = [ud.handles.menu, handles];
  ud.imp = imp;
  set(CFh, 'MenuBar', 'None');
  set(CFh, 'UserData', ud);
  % Initial ``update''
  impplotUpdate(CFh); 
endfunction


function impplotUpdate(CFh)
% -------------------------------------------------------------------------
% impplotUpdate simply (re)-plots the data according to the plot type
% required.
% -------------------------------------------------------------------------

  ud =get(CFh, 'UserData');
  chk = findobj(ud.handles.stored.formats, 'Checked', 'On');
  indx = (ud.handles.stored.formats(:) == chk);

  % Pseudo Switch
  % case 'Smith_Chart'
  if indx(1)
%  set(ud.dataAx, 'Visible', 'Off');
    set(ud.dataAx, 'DataAspectRatio', [1 1 1], 'XLim', [-1 1],...
      'YLim', [-1 1]);
    smithgrid(CFh);
    % dataAx vis off. aspect 111 xlim -1 1 ylim -1 1
    % for i =1:noLines
    rho = (ud.imp.impedance - ud.Zo)./(ud.imp.impedance + ud.Zo);
    line (real(rho), imag(rho),'ButtonDownFcn','impplot;','Tag','impline');

    %line stuff, smithgrid stuff.
  endif
  if indx(2)
    %MagPhs
    % Kill previous axes?????? Or simply get rid of Smith, then plot()
    %
%    plot 

  endif
  % etc
endfunction
