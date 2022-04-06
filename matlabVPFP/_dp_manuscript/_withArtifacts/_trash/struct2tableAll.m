function tab = struct2tableAll(s,varargin)
% STRUCT2TABLEALL Convert array of structs and array of nested structs to table
% This function is an improved version of MATLAB built-in function struct2table
%
% SYNTAX:
%  tab = struct2tableAll(s)
%  tab = struct2tableAll(___,varargin)
%
% INPUT:
%   s         = struct
%   prefix    = Variable prefix (string, ddefault = '')
%   splitVars = Split multicolumn variables in table (true | false = default)
%
% OPTIONS:
%   Class     =  Class filter, e.g. 'double' | 'char' | string | table | function_handle | '' default => no filter
%   Type      =  Type filter, 'scalar' | 'nonscalar' | 'empty' | 'nonempty' | '' default => no filter
%   Depth     =  Max Depth filter, positve integer 0 = no filter (default)
%   SplitVars =  Split multicolumn variables in table, true | false (default)
%
% OUTPUT:
%   tab = Output table
%
% EXAMPLE:
%   tab = struct2tableAll(s)
%   tab = struct2tableAll(s,'SplitVars',true)
%   tab = struct2tableAll(s,'Class',{''},'Type','scalar','Depth',2)
%
% CHANGELOG:
%   V1.00: First version
%
% INFO:
%   Copyright 06-2020, Uhlending, Markus
%   Matlab version   : Matlab 2020a
%   Function version : 1.00, 2020-06-08
%   Released under the BSD license.
%
% See also flattenStruct, struct2table, splitvars, fieldnamesAll

try
    %% Check input
    p = inputParser;
    p.KeepUnmatched = 1;
    addRequired(p,'s',@(x)validateattributes(x,{'struct'},{},mfilename,'s',1))
    addParameter(p,'SplitVars',false,@(x)validateattributes(x,{'numeric','logical'},{'nonempty'},mfilename,'SplitVars'));
    
    parse(p,s,varargin{:})
    s         = p.Results.s;
    SplitVars = logical(p.Results.SplitVars);
    
    % Get all Unmatched parameters fro sub fuctions
    varargin = namedargs2cell(p.Unmatched);
    
    %% Convert all structs to flatten struct
    s0 = s;
    for ii = 1:numel(s0)
        s = s0(ii);
        s1(ii) = flattenStruct(s,varargin{:}); %#ok<AGROW>
    end
    
    %% Convert all structs to table
    tab = struct2table(s1,'AsArray',true);
    
    %% Split table vars, if requested
    if SplitVars
        tab = splitvars(tab); % Split multicolumn variables in table
    end
catch ME
    ME = MException('MATLAB:struct2tableAll','%s',ME.message);
    throw(ME)
end
end