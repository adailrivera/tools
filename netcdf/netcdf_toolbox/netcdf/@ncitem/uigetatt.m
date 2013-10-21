function theResult = uigetatt(self)

% ncitem/uigetatt -- Get a NetCDF attribute via dialog.
%  uigetatt(self) returns one attribute associated with self,
%   an "ncitem" object, selected from a list-dialog.  The
%   returned value is an "ncatt" object, or the empty-matrix
%   [] if no variable is selected.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 01-Dec-1997 13:20:58.

if nargin < 1, help(mfilename), return, end

result = [];

theParent = parent(parent(self));
theFilename = name(theParent);
f = find(theFilename == filesep);
if any(f)
   theFilename(1:f(length(f))) = '';
end

theAtts = att(self);
theAttnames = ncnames(theAtts);
if ~isempty(theAttnames)
   thePrompt = {'Select Attribute From', 'NetCDF File', ['"' theFilename '"']};
   theSelection = listdlg('ListString', theAttnames, ...
                          'SelectionMode', 'single', ...
                          'PromptString', thePrompt);
   if any(theSelection)
      result = theAtts{theSelection};
   end
else
   disp(' ## No attributes available.')
end

if nargout > 0
   theResult = result;
else
   ncans(result)
end
