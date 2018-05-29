% markers.m
%
% Generic facility to allow markers on a plot. User clicks on a plot line()
% object, and what we want is a stadard HP-VNA ``marker'' with an info
% panel with data about the exact point.
%
% Want to be able to move them, delete them, etc. The marker must only be
% attached to an ACTUAL data point, and as the format of the plot changes
% (Smith Chart, VSWR, impedance etc), we want the marker to ``stick'' to
% the data point, and the correct value is reflected in the markerlegend.
%
% markers() requires the plot to store several things and handles in its
% UserData such that a seamless integration takes place. ie a handle
% required in this file must have its counterpart in the plot UserData.
%
% The plot must construct the lines with ButtonDownFcn's linked to a
% SwitchYard for the CallBack. The main *ACTUAL* call is simply
% markers('update'); But markers() calls itself via modifying other
% callbacks, ButtonUpFcns etc, etc, but these are private to this file.
%
% marker Number is stored in the marker UserData.
%
% 20180526 AlanRobertClark@gmail.com

function markers(action, CFh, number)
% -------------------------------------------------------------------------
% SwitchYard-Type structure, to handle one external call 'update', and all
% the private calls.
% -------------------------------------------------------------------------

  if nargin < 2
    CFh = get(0, 'CurrentFigure');
  endif
  CBh = get(0, 'CallBackObject');
  ud = get(CFh, 'UserData');

  switch(lower(action))
    case 'update'
      updatemarkers(CFh);

    % Private actions, triggered internally.
    % 'down': existing marker was clicked on
    case 'down' 
      mrkNum = get(CBh, 'UserData');
      switch(get(CFh, 'SelectionType'))
        case 'normal' % Left-click: Move it. Ensure ONLY ONE callback.
          set(CFh, 'Interruptible', 'Off', 'BusyAction', 'Cancel',...
            'WindowButtonMotionFcn',...
              sprintf('markers(''motion'', CFh, %g);', mrkNum),...
            'WindowButtonUpFcn',...
              sprintf('markers(''up'', CFh, %g);', mrkNum));
          % speed up erasemode. No evidence of 'markermotion' Do I really
          % need to pass CFh???
        case 'alt' % Right-click: delete marker.
          % delete ud.markers(mrkNum).mrkH .textH, .legH
          % ud.m(mN)=[]; set ud
          % updatemarkers(CFh)
          delete([ud.markers(mrkNum).mrkH,...
            ud.markers(mrkNum).textH]);
          ud.markers(mrkNum) = [];
          set(CFh, 'UserData', ud);
          updatemarkers(CFh);
      endswitch

    % marker still clicked on, being dragged The call includes number :-).
    case 'motion'
      mrkNum = number;
      % Shit. CBh is the fucking marker, not the line it is on. Therefore
      % must store the line handle in the actual Marker data...........
      
      xdata = get(ud.markers(mrkNum).lineH, 'XData');
      
      %
      %
      %
      %
      %
      %

    % User let go of the clicked-and-dragged marker.
    case 'up'
      set(CFh, 'WindowButtonMotionFcn', '', 'WindowButtonUpFcn', '');
      updatemarkers(CFh);
  endswitch

endfunction

function updatemarkers(CFh)
% -------------------------------------------------------------------------
% (Re)draws the markers, including the markerlegend stuff. Why seperate?
% Offsets are calculated in y direction only, and require a linear yaxis.
% For a dB yaxis, we will have to get more interactive with the calling
% program, and do an exponential offset. ToBeRevisited :-)
%
% We will also worry about how MagPhs Real/Imag gets done later.
% -------------------------------------------------------------------------
  ud = get(CFh, 'UserData');

  for i = 1:numel(ud.markers);
    % ud.marker(i).lineH is the line, and is the current CallBack Object.
    lnAx = get(ud.markers(i).lineH, 'Parent');
    yl = get(lnAx, 'YLim');
    % Linear
    markerOfs = 0.015 * diff(yl);
    textOfs = 0.042 * diff(yl);
    xdata = get(ud.markers(i).lineH, 'XData');
    ydata = get(ud.markers(i).lineH, 'YData');
    xpos = xdata(ud.markers(i).index);
    ypos = ydata(ud.markers(i).index);
    if ishandle(ud.markers(i).mrkH)
      set(ud.markers(i).mrkH, 'XData', xpos, 'YData', ypos + markerOfs,...
        'UserData', i);
      % Nothing else changes in a pre-existing marker (or text).
      set(ud.markers(i).textH, 'Position', [xpos, ypos + textOfs],...
        'UserData', i, 'String', num2str(i));
    else
      % Create for the first time in the same axes.
      lnCol = get(ud.markers(i).lineH, 'Color');
      ud.markers(i).mrkH = line('Parent', lnAx,...
        'XData', xpos, 'YData', ypos + markerOfs,...
        'Marker', 'v', 'MarkerSize', 10, 'Color', lnCol,...
        'UserData', i,...
        'Tag', 'marker', 'ButtonDownFcn', 'markers down');
      ud.markers(i).textH = text('Parent', lnAx,...
        'Position', [xpos, ypos + textOfs], 'Color', lnCol,...
        'String', num2str(i), 'HorizontalAlignment', 'Center',...
        'UserData', i,...
        'Tag', 'marker', 'ButtonDownFcn', 'markers down');

        % Note erasemode does no longer exist.
        % % simply the ith marker. No need to store i. But if I click on
        % text, CBh is not the mrkH.... UserData way to go? YEP.
        % Fontsize difference of 1 point irrelevant. ZData irrelevant.
        % Clipping irrelevant.
    endif
    % At this point, refresh the marker legend data......
  endfor
  set(CFh, 'UserData', ud);

endfunction









% Internal calls:
% 'down' User clicks down on marker
% 'motion' Previously clicked down, still down, but moving.
% 'up' Let go after dragging.




% ud.markers documentation. This is needed in the calling application.
% Want to minimise what is required!
%
% ud.markers(i).mrkH  Handle to the marker object (single point line).
% ud.markers(i).textH Handle to the text object of that marker.
% ud.markers(i).lineH Handle to the plot line that the marker is on.
% ud.markers(i).index The index of the data point of the line marker.



