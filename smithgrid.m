% smithgrid: Plots the Smith Chart grid with seperate Tags.
%
% figH = smithgrid (CFh);
%   Plots a smith chart grid in the figure handle CFh, in the
%   *CurrentAxes*. The basics of the Smith Chart are Tagged `smith'. The
%   actual grid itself is tagged `smithgrid', to allow the grid to be
%   turned off separately from the whole chart.
%
% figH = smithgrid;
%   Creates a new figure, and just puts up a smith chart grid.
%
% Most often called without an output argument, but can return the figure
% handle (CFh).


function figH = smithgrid(CFh);
% -------------------------------------------------------------------------
% Creates a standard Smith Chart. 
% -------------------------------------------------------------------------

  if ((nargin < 1) || ~ishandle(CFh))
    CFh = figure;
  end;

  theta = linspace(0, 2*pi)';

  % : [0 0 0] for traditional plots, but ugly.
  lns = '-';
  col = [0.8 0.8 0.8];

  if strcmpi(graphics_toolkit, 'gnuplot')
    patch (cos(theta), sin(theta), 'w', 'Tag', 'smith');
  endif
  % Set up Constant Resistance Circles, Constant Reactance Circles,
  % Constant VSWR circles, and the real axis.
  ConstR([0.2 0.5 1 2 5]);
  ConstX([0.2 0.5 1 2],[1 2 5 5]);
  ConstVSWR([2]);
  % Consensus is that the real line is not optional :-)
  line ([-1 1], [0 0], 'LineStyle', lns, 'Color', col, 'Tag','smidfith');

  % Do a bit of fiddling to get the text scale positioned...
  text(-1.05, -0.03, '0',   'Tag', 'smithgrid');
  text(-0.71, -0.03, '0.2', 'Tag', 'smithgrid');
  text(-0.37, -0.03, '0.5', 'Tag', 'smithgrid');
  text( 0.01, -0.03, '1',   'Tag', 'smithgrid');
  text( 0.34, -0.03, '2',   'Tag', 'smithgrid');
  text( 0.68, -0.03, '5',   'Tag', 'smithgrid');
  handle = text(1.01, -0.03, '\infty', 'Tag', 'smithgrid');
  set (handle, 'Fontsize', 15);

  text(-1.02,  0.4,   '0.2', 'Tag', 'smithgrid');
  text(-1.05, -0.4,  '-0.2', 'Tag', 'smithgrid');
  text(-0.7,   0.82,  '0.5', 'Tag', 'smithgrid');
  text(-0.73, -0.81, '-0.5', 'Tag', 'smithgrid');
  text(-0.02,  1.04,  '1',   'Tag', 'smithgrid');
  text(-0.03, -1.04, '-1',   'Tag', 'smithgrid');
  text( 0.60,  0.84,  '2',   'Tag', 'smithgrid');
  text( 0.6,  -0.83, '-2',   'Tag', 'smithgrid');

  % Grey circles with full lines (as opposed to the black dotted lines)
  % overwrite the outer black circle of the patch. Simplest solution is to
  % draw the patch *last*. White fill does not obscure grid in Qt or fltk,
  % but does in gnuplot. Hence First in gnuplot.....
  if ~strcmpi(graphics_toolkit, 'gnuplot')
    patch (cos(theta), sin(theta), 'w', 'Tag', 'smith');
  endif

  % Special case for just a chart :-)
  if nargin < 1
    CAh = get (CFh, 'CurrentAxes');
    set (CAh, 'Visible', 'Off', ...
      'DataAspectRatio', [1 1 1]);
  end;

  if nargout > 0
    figH = CFh;
  end;
  
  function ConstR(r);
  % -------------------------------------------------------------------------
  % Nested for lns, col, theta access.
  % Plots a circle of Constant Resistance (r is normalized Ohms).
  % These are defined as having centres of (r/(1+r),0) and radii
  % of 1/(1+r). The order of the multiplications is necesary to
  % allow FULL VECTORIZATION!! ie ConstR([0 0.2 0.5 1 2 5])
  % -------------------------------------------------------------------------
    radius = 1./(1+r);
    x = cos(theta)*radius + ones(size(theta))*(r./(1+r));
    y = sin(theta)*radius;
    line (x,y, 'LineStyle', lns, 'Color', col, 'Tag', 'smithgrid');
  endfunction
  
  function ConstX(x,endR);
  % -------------------------------------------------------------------------
  % Nested for lns, col access.
  % Plots a (partial) circle of constant reactance (x is normalized Ohms)
  % the ``circle'' starts at 0 (on the unit circle) and ends at endR
  % resistance to stop clutter on the chart. Called as
  % ConstX([0.2 0.5 1 2], [1 2 5 5]);
  % -------------------------------------------------------------------------
    z = linspace(0, 1).' * endR + j * ones(100,1) * x;
    rho = (z-1)./(z+1);
    line (real(rho), imag(rho), 'LineStyle', lns, 'Color', col, ...
      'Tag', 'smithgrid');
    line (real(rho), -imag(rho), 'LineStyle', lns, 'Color', col, ...
      'Tag', 'smithgrid');
  endfunction
  
  
  function ConstVSWR(VSWR);
  % -------------------------------------------------------------------------
  % Nested for lns, col, theta access.
  % Simply plots a circle at the constant VSWR specified.
  % Can be called as ConstVSWR([1.5 2 2.5 3])
  % -------------------------------------------------------------------------
    mag = abs((1-VSWR)./(1+VSWR));
    line (cos(theta)*mag, sin(theta)*mag, 'LineStyle', lns, 'Color', col,...
      'Tag', 'smithgrid');
  endfunction

endfunction
