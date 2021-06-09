function h = scattertext(x,y,c,varargin)
% scattertext creates color-scaled text labels.   
% 
%% Syntax 
% 
% scattertext(x,y,c) 
% scattertext(...,text) 
% scattertext(...,'colormap',ColorMap) 
% scattertext(...,'TextProperty',TextValue) 
% scattertext(...,'clim',[cmin cmax]) 
% h = scattertext(...) 
% 
%% Description 
% 
% scattertext(x,y,c) places numeric values c as text labels centered
% on x,y and color-scaled to the values of c using the current colormap.         
% 
% scattertext(...,text) scales color of cell array text to values of c.    
% 
% scattertext(...,'colormap',ColorMap) specifies a colormap for text, and
% does not hijack the current colormap or affect the colorbar in any way.   
% 
% scattertext(...,'TextProperty',TextValue) formats text labels with
% fontweight, fontangle, etc. 
% 
% scattertext(...,'clim',[cmin cmax]) specifies limits of color scaling. 
% This can be useful if you want to match label colors to current color 
% axis limits.  That'd be accomplished with ...,'clim',caxis). By default, 
% limits are [min(c) max(c)]. 
% 
% h = scattertext(...) returns a label handle h.  
% 
%% Example 1: Formatting examples: 
% 
% % Using this data:
% x = rand(6,1); 
% y = rand(6,1); 
% z = round(20*rand(6,1)-5); 
% t = {'dog','cat','pants','lasagna','archduke','sandwiches'}'; 
% 
% subplot(221) 
% scattertext(x,y,z) 
% title 'make color-scaled z values:'
% 
% subplot(222)
% scattertext(x,y,z,'fontweight','bold','fontsize',40)
% title 'format text:'
% 
% subplot(223)
% scattertext(x,y,z,t)
% title 'scale text labels by z values:'
% 
% subplot(224)
% scattertext(x,y,z,t,'colormap',autumn)
% title 'specify a colormap:' 
% 
%% Example 2: Match label colors with contour color map.  
% 
% % Some gridded surface data: 
% [X,Y,Z] = peaks(500); 
% contour(X,Y,Z)
% 
% % Find z values at some points: 
% xi = 2*randn(25,1); 
% yi = 2*randn(25,1); 
% zi = interp2(X,Y,Z,xi,yi); 
% zi = round(zi*10)/10; 
% 
% % Match label colors to contour colors:  
% scattertext(xi,yi,zi,'clim',caxis)
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas 
% at Austin's Institute for Geophysics, June 2015.  Visit Chad at 
% http://www.chadagreene.com if you have any questions or comments. 
% 
% See also text, scatter, clabel, caxis, colormap.  

%% Initial error checks: 

narginchk(3,inf)
assert(numel(x)==numel(y),'Inputs x, y, and z must be same size.'); 
assert(numel(x)==numel(c),'Inputs x, y, and z must be same size.'); 
assert(isnumeric(x)==1,'Input x must be numeric.') 
assert(isnumeric(y)==1,'Input y must be numeric.') 
assert(isnumeric(c)==1,'Input c must be numeric values by which colors are scaled.') 

%% Set defaults: 

cmap = colormap;              % Current color map.
txt = cellstr(num2str(c(:))); % Assume labels are given by c. 
clim = [min(c(:)) max(c(:))]; % Color limits. 

%% Parse inputs: 

if nargin>3
    
    % Possible properties user can set: 
    props = {'fontname','fontsize','fontunits','fontangle','fontweight','fontsmoothing',...
    'interpreter','edgecolor','backgroundcolor','margin','linestyle','linewidth',...
    'rotation','units','clipping','handlevisibility','colormap','color','col','cmap',...
    'horiz','horizonalalignment','vert','verticalalignment','clim'}; 

    % If first varargin is not one of the properties listed above, assume it's the 
    % text the user wants to place on figure: 
    tmp = ismember(props,varargin{1}); 
    if ~any(tmp)
        txt = varargin{1}; 
        tmp = zeros(1,length(varargin)); 
        tmp(1) = 1; 
        varargin = varargin(~tmp); 
        assert(length(txt)==numel(c),'Input text must be the same size as x, y, and z.')
        
    end        
        
    % Let user specify a colormap: 
    tmp = strncmpi(varargin,'colormap',3) | strcmpi(varargin,'cmap'); 
    if any(tmp) 
        cmap = varargin{find(tmp)+1}; 
        tmp(find(tmp)+1)=1; 
        varargin = varargin(~tmp); 
    end
    
    % Let user specify a data range other than limits of c:    
    tmp = strcmpi(varargin,'clim'); 
    if any(tmp) 
        clim = varargin{find(tmp)+1}; 
        tmp(find(tmp)+1)=1; 
        varargin = varargin(~tmp); 
        assert(numel(clim)==2,'Color range must be a two-element vector in the form [cmin cmax].')
    end
    
    
end

%% 

% Columnate inputs: 
x = x(:); 
y = y(:); 
c = c(:); 

% Create colorc, which is an indexed form of colors in colormap corresponding 
% to the range of input c values: 
ncolors = size(cmap,1);
if ncolors==1
    cmap = [cmap;cmap]; 
    ncolors = 2; 
end
colorc = linspace(clim(1),clim(2),ncolors); 

% Interpolate to get textcolors:  
r = interp1(colorc,cmap(:,1),c); 
g = interp1(colorc,cmap(:,2),c); 
b = interp1(colorc,cmap(:,3),c); 
% textcolor = [r g b]; 
textcolor = [zeros(size(r)) zeros(size(g)) zeros(size(b))];
% Place and format labels: 
for k = 1:length(txt)
    if isfinite(c(k)) % Ignores NaNs. 
        if isempty(varargin)
            h(k) = text(x(k),y(k),txt{k},'horiz','center','vert','middle','color',textcolor(k,:));
        else
            h(k) = text(x(k),y(k),txt{k},'horiz','center','vert','middle','color',textcolor(k,:),varargin{:});
        end
    end
end


%% Clean up:

if nargout==0 
    clear h
end


end