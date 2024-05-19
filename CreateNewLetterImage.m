function [I,A,H,W] = CreateNewLetterImage(str,pad,varargin)
if nargin<1 || isempty(str)
    str = 'Abc';
end
if nargin<2 || isempty(pad)
    pad = 0; 
end 
slow_but_reliable = true;
 
if ischar(pad)
    varargin = [pad varargin]; 
    pad = 0; 
end 
if numel(pad)==1
    pad = pad*[1 1 1 1]; 
end
if numel(pad)==2 
    pad = [pad;pad]; 
end
crop = ~isfinite(pad(:)); 
pad(crop) = 0;
if isnumeric(str) 
    str = char(str); 
end
 
fig = figure;clf
set(fig,'Units','pixels','Color',[1 1 1],'MenuBar','none') 
axe = axes('Parent',fig,'Position',[0 0 1 1],'Visible','off'); 
try
    txt = text('Parent',axe,'Interpreter','none','FontSize',16,'String',str,varargin{:},'Units','pixels'); 
    drawnow 
    ext = ceil(get(txt,'Extent')); 
    pos = get(txt,'Position');
    set(txt,'Position',[1+pos(1)-ext(1)+pad(1) 1+pos(2)-ext(2)+pad(4)]); 
    W = ceil(ext(3))+pad(1)+pad(2)+1; 
    H = ceil(ext(4))+pad(3)+pad(4)+1; 
    set(fig,'Position',[0 0 W H]) 
    drawnow
    pos = get(fig,'Position');
    if any([W H]-pos(3:4)>1)
        warning('Image is %.1f%% too large to fit on screen.',(max([W H]./pos(3:4))-1)*100)
    end
catch ex
    close(fig) 
    rethrow(ex) 
end
if any(pad(:)>0) && ~isequal(get(txt,'BackgroundColor'),'none') 
    set(fig,'Color',get(txt,'BackgroundColor')) 
end
if slow_but_reliable
    set(fig,'InvertHardcopy','off')
    I = print(fig,'-RGBImage','-r96');
    I = I(:,1:min(W,end),:); 
else
    I = frame2im(getframe(fig,[0 0 W H])); %#ok<UNRCH> %capture rgb image [left bottom width height]
end
if nargout>1 
    set(txt,'Color','k','BackgroundColor','w')
    set(fig,'Color','w') 
    if slow_but_reliable
        set(fig,'InvertHardcopy','off')
        A = print(fig,'-RGBImage','-r96');
        A = A(:,1:W,:);
    else
        A = frame2im(getframe(fig,[0 0 W H])); %#ok<UNRCH> %capture rgb image [left bottom width height]
    end
    A = rgb2gray(255-A);
end
[H,W,~] = size(I); 
if size(I,2)~=W || size(I,1)~=H
    warning('str2im:TextLargerThenScreen','Text image was cropped because it did not fit on screen.')
end
if any(crop) 
    [H,W,~] = size(I);
    t = any(any(abs(diff(I,[],1)),3),1); 
    if crop(1) && any(t), L = max(find(diff([0 t]),1,'first')-1,1); else, L = 1; end
    if crop(2) && any(t), R = min(find(diff([t 0]),1,'last' )+1,W); else, R = W; end
    t = any(any(abs(diff(I,[],2)),3),2); 
    if crop(3) && any(t), T = max(find(diff([0;t]),1,'first')-1,1); else, T = 1; end
    if crop(4) && any(t), B = min(find(diff([t;0]),1,'last' )+1,H); else, B = H; end
    I = I(T:B,L:R,:); 
    if nargout>1
        A = A(T:B,L:R,:); 
    end
    [H,W,~] = size(I);
end
close(fig) 
if ~nargout 
    imagesc(I)
    axis equal tight
    clear I
end