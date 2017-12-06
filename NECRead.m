# NECRead
#
# OK, the great NEC File Parser.
#
# Implemented simply in octave ``C'' I/O collecting everything a NEC file
# has and putting it together with the structure. This could be simply an
# impedance run, a gain run, radpat cuts, or fully blown 3D animations :-)
# Extract the data and play with it later.
#
# Make sure there is a structure :-)
#
# Assumptions: ONLY ONE structure: NX cards are not useful in any case.
#              Wire segments only at this stage.
#              Do loadings etc later.
#              We will do purely procedural code.


function NECRead(filename);
  # open file, and ensure correctness.
  fid = fopen (filename, "rt");
  if fid < 0
    error ('Could not open %s',filename);
  endif

  # Get Database Handle....
  ud = get(gcf(),'UserData')
  ud.Frequency = [];
  ud.Impedance = [];
  ud.Radpat = [];
  set (gcf(),'UserData',ud)

  # So now we want to read line-by-line, categorising the data correctly
  # and storing it away.......
  # Subfunctions may be used to gather the appropriate segments of the
  # file.

  # First need the structure.....
  # Read a line, search for the relevant substrings. Call the relevant
  # routines to deal with the data, return.....

  while (! feof(fid))
    textline = fgetl (fid)

    if findstr('- - - STRUCTURE SPECIFICATION - - -', textline)
      CollectStructureSpecification(fid);
    endif

    if findstr('- - - - SEGMENTATION DATA - - - -', textline)
      CollectSegmentationData(fid);
    endif

    if findstr('- - - - - - FREQUENCY - - - - - -', textline)
      CollectFrequency(fid);
    endif

    if findstr('- - - STRUCTURE IMPEDANCE LOADING - - -', textline)
      CollectStructureImpedanceLoading(fid);
    endif

    if findstr('- - - ANTENNA INPUT PARAMETERS - - -', textline)
      CollectAntennaInputParameters(fid);
    endif

    if findstr('- - - CURRENTS AND LOCATION - - -', textline)
      CollectCurrentsAndLocation(fid);
    endif

    if findstr('- - - RADIATION PATTERNS - - -', textline)
      CollectRadiationPatterns(fid);
    endif
  endwhile
endfunction





function CollectStructureSpecification(fid);
  # skip 8 lines to start of Specification;
  nlines = fskipl (fid, 8)

  # while the line is not blank, read %i%f%f%f%f%f%f%f%i%i%i%i
endfunction

function CollectSegmentationData(fid);
  # Skip 8 lines...
  nlines = fskipl ( fid, 8 )

  # while line is not blank, read %i%f%f%f%f%f%f%f%i%i%i%i
  textline = fgetl (fid);
  while (length(textline)>0)
    sscanf (textline, '%d','C')
    textline = fgetl (fid);
  endwhile  
endfunction

function CollectFrequency(fid);
  # Skip 1 line
  nlines = fskipl ( fid, 1 )
  
  # Read, and convert.
  textline = fgetl (fid)
  [scratch, freq, count, errmsg] = sscanf (textline,'%s%e' ,"C")

  # Add to data structure.....
  ud = get(gcf(), 'UserData')
  ud.Frequency = [ud.Frequency, freq]
  set(gcf(), 'UserData',ud) 


endfunction

function CollectStructureImpedanceLoading(fid);
  # Skip 1 line
  nlines = fskipl ( fid, 1 )
endfunction

function CollectAntennaInputParameters(fid);
  # ONLY reads first excitation....

  # Skip 3 lines
  nlines = fskipl ( fid, 3 )

  textline = fgetl (fid);
  [iScr,iScr,eScr,eScr,eScr,eScr,impReal,impImag count,errmsg] = sscanf ...
    (textline, '%d%d%e%e%e%e%e%e' ,"C")
  ud = get(gcf(), 'UserData');
  ud.Impedance = [ud.Impedance, impReal + j.*impImag];
  set (gcf(), 'UserData', ud);
endfunction

function CollectCurrentsAndLocation(fid);
  # Skip 1 line
  nlines = fskipl ( fid, 1 )
endfunction

function CollectRadiationPatterns(fid);
  # Skip 4 lines
  nlines = fskipl ( fid, 4 )

  textline = fgetl (fid);
  [theta,phi,Gv,Gh,Gt] = sscanf (textline, '%e%e%e%e%e', 'C');
  ud=get(gcf(), 'UserData');
  ud.Radpat = [ud.Radpat, Gt];
  set (gcf(), 'UserData', ud);

endfunction


