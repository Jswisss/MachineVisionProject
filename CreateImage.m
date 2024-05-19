function [I,A,H,W] = CreateImage(T,varargin)
persistent D P 
if nargin>=2
    P = varargin; 
end
if nargin>=1 && (isnumeric(T) && isempty(T) || isstruct(T))
    D = T; return 
end
if nargin==0
    I = D; return 
end
%check
if isnumeric(D), D = struct('str',{}); end 
if isnumeric(P), P = cell(0,0); end 
if ischar(T),    T = num2cell(T); end 
if ~isnumeric(T)
    i = arrayfun(@(x)isequal(P,x.props),D);
    U = unique(T(:)');
    for k = find(~ismember(U,{D(i).str}))
        D(end+1).str = U{k};
        [D(end).image,D(end).alpha,D(end).height,D(end).width] = CreateNewLetterImage(U{k},P{:});
        D(end).props = P;
    end
    i = find([i true(1,numel(D)-numel(i))]); 
end
if nargout>0
    if ~isnumeric(T)
        [~,j] = ismember(T,{D(i).str}); 
        j = i(j);
    else
        j = T;
    end
    I = cell2mat(reshape({D(j).image},size(T))); 
end
if nargout>1
    A = cell2mat(reshape({D(j).alpha},size(T)));
end
if nargout>2
    [H,W,~] = size(I);
end
