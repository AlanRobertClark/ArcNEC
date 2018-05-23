% NECReadZin
%
% Read *ALL* impedances in the file, with the frequencies, and return an
% ``impstruct'' as per impplot requirements structure with .freq(nfx1) of
% frequencies in MHz, and .imp a vector of complex impedances in
% Ohms(nFx1).
%
% 20180521 AlanRobertClark@gmail.com 

function impstruct = NECReadZin(filename)
% -------------------------------------------------------------------------
% Returns the impstruct from the filename.
% -------------------------------------------------------------------------
  fid = fopen (filename, "rt");
  if fid < 0
    error('Could not open %s',filename);
  endif

  while (~feof(fid))
    textline = fgetl (fid);

    if strfind(textline, '- - - - - - FREQUENCY - - - - - -');
      fskipl(fid, 1);
      [~, impstruct.freq(end+1)] = fscanf(fid, '%s%e', 'C');
    endif

    if strfind(textline, '- - - ANTENNA INPUT PARAMETERS - - -');
      fskipl(fid, 3);
      [~,~,~,~,~,~, impReal, impImag] = fscanf(fid,'%d%d%e%e%e%e%e%e' ,'C');
      impstruct.impedance(end+1) = complex (impReal,impImag);
    endif
  endwhile
  fclose(fid);
  if numel(impstruct.freq) ~= numel(impstruct.impedance)
    error('No. of frequencies not equal to No. of impedances');
  endif
endfunction

