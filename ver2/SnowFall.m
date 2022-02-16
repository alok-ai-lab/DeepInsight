function [xps,yps,As,Bs]=SnowFall(xp,yp,FIG,A,B)
% [xps,yps,As,Bs]=SnowFa;;(xp,yp,FIG,A,B)
% Snowfall compression algorithm for DeepInsight

if nargin<3
    FIG=0;
end

% change y-axis so that it can be related with Cartesian Coordinates
if size(xp,1)>size(xp,2)
    xp=xp';
    yp=yp';
end
yp=-yp;

z = [xp;yp];
M = mean(z',1)';
M = round(M);
L = length(xp);

if FIG==1
% figure % remove after testing;
Ainit=abs(max(xp)-min(xp))+1;
Binit=abs(max(yp)-min(yp))+1;
N=max([Ainit,Binit]);
disp_cnt=1;
if N<200
%N=100;
    X=ones(N);
    idx=sub2ind(size(X),xp,-yp);
    X(idx)=0;
    figure; imagesc(X'); grid on;
    %M(1)=49;%11;%5;%3;%5;
    %M(2)=-50;%-12;%-6;%-4;%-6;
    hold on; 
    X(M(1),-M(2))=0.5;  
    imagesc(X');
    hold off;
    pause(0.5);
    F(1)=getframe(gcf);
    drawnow
    im_cnt=2;
else
    disp('size of pixel frame is very large');
end
%###################
end

%center
xc=M(1);
yc=M(2);

% distance of {xp,yp} from center {xc,yc}
for j=1:L
   D(j)=norm(z(:,j)-M);
end

[d,inx]=sort(D);
center_taken = 0;

for j=1:L
   xpn = xp(inx(j));
   ypn = yp(inx(j));
   zpn=[xpn;ypn];

   % Find samples in area A
   if xpn<=xc & yc <= ypn
      % Quadrant 1
      %search xp <= xu <= xc   and yc <=yu <= yp
      r=[(z(1,:)<=xc & z(1,:)>=xpn);(z(2,:)<=ypn & z(2,:) >= yc)];
      r=and(r(1,:),r(2,:));
      zu=z(:,r); % xu and yu in area A
   elseif xpn <= xc & ypn <= yc
      % Quadrant 2
      %search xp <= xu <= xc   and yp <= yu < yc
      r=[(z(1,:)<=xc & z(1,:)>=xpn);(z(2,:)<= yc & z(2,:) >= ypn)];
      r=and(r(1,:),r(2,:));
      zu=z(:,r); % xu and yu in area A
   elseif xpn >= xc & yc >= ypn
      % Quadrant 3
      %search xp >= xu > xc   and yc >= yu >= yp
      r=[(z(1,:) >= xc & z(1,:) <= xpn);(z(2,:)<= yc & z(2,:) >= ypn)];
      r=and(r(1,:),r(2,:));
      zu=z(:,r); % xu and yu in area A
   elseif xpn >= xc & ypn >= yc
      % Quadrant 4
      %search xp >= xu > xc   and yp >= yu > yc
      r=[(z(1,:) >= xc & z(1,:) <= xpn);(z(2,:) >= yc & z(2,:) <= ypn)];
      r=and(r(1,:),r(2,:));
      zu=z(:,r); % xu and yu in area A
   end
   
   %Gradient of point xpn and ypn wrt xc and yc
   m = (ypn-yc)/(xpn-xc);
   if isnan(m)==1
       m=0;
   end

   
   if sum(r)<=2
       % If no point at xc,yc then place a point
       if center_taken == 0
           xp_prime = xc;
           yp_prime = yc; 
      	   center_taken = 1;
       else
           % only two points in a given area A ({xp,yp} and {xc,yc})
           if m==0
               if xpn < xc
                   xp_prime = xc - 0.5;
                   yp_prime = yc;
               else
                   xp_prime = xc + 0.5;
                   yp_prime = yc;
               end
           elseif isinf(m)==1
               if ypn < yc
                   yp_prime = yc - 0.5;
                   xp_prime = xc;
               else
                   yp_prime = yc + 0.5;
                   xp_prime = xc;
               end
           else
               if xpn < xc
                   xp_prime = xc - 0.5;
                   yp_prime = m*xp_prime + (yc - m*xc);
               else
                   xp_prime = xc + 0.5;
                   yp_prime = m*xp_prime + (yc - m*xc);
               end
           end
           clear xp_tmp yp_tmp dcp xi_tmp yi_tmp dcp
           xp_tmp(1) = floor(xp_prime); yp_tmp(1) = floor(yp_prime);
           xp_tmp(2) = floor(xp_prime); yp_tmp(2) = ceil(yp_prime);
           xp_tmp(3) = ceil(xp_prime); yp_tmp(3) = floor(yp_prime);
           xp_tmp(4) = ceil(xp_prime); yp_tmp(4) = ceil(yp_prime);
           Cond=[];
           for cnd=1:4
               if xc==xp_tmp(cnd) & yc==yp_tmp(cnd)
                   Cond = [Cond,cnd];
               end    
           end
           % ensure no overlaps
           TotalCnd=1:4;
           if length(Cond)>0
               Y=TotalCnd~=Cond(1);
               if length(Cond)>1
                   for cnd=1:length(Cond)
                       Y=and(Y,TotalCnd~=Cond(cnd));
                   end    
               end
               LeftCond = TotalCnd(Y);
               if m~=0 & isinf(m)~=1
                   xi_tmp = ((yp_tmp(LeftCond) + xp_tmp(LeftCond)./m) - (yc - m*xc))/(m+1/m);
                   yi_tmp = m.*xi_tmp + (yc - m*xc);
                   clear dpi_tmp
                   dpi_tmp = sqrt((xi_tmp-xp_tmp(LeftCond)).^2 + (yi_tmp-yp_tmp(LeftCond)).^2); 
                   [row,inx_pi_tmp]=min(dpi_tmp);
                   inx_pi_tmp=LeftCond(inx_pi_tmp);
                   xp_prime = xp_tmp(inx_pi_tmp);
                   yp_prime = yp_tmp(inx_pi_tmp);
               else
                   dcp=sqrt((xc-xp_tmp(LeftCond)).^2 + (yc-yp_tmp(LeftCond)).^2); 
                   [row,inx_cp]=min(dcp);
                   inx_cp=LeftCond(inx_cp);
                   xp_prime = xp_tmp(inx_cp);
                   yp_prime = yp_tmp(inx_cp);
               end
           else    
               if xpn < xc
                   xp_prime = floor(xp_prime);
               else
                   xp_prime = ceil(xp_prime);
               end
               if ypn < yc
                   yp_prime = floor(yp_prime);
               else
                   yp_prime = ceil(yp_prime);
               end       
           end
      
           

%            if xpn < xc
%                xp_prime = floor(xp_prime);
%            else
%                xp_prime = ceil(xp_prime);
%            end
%            if ypn < yc
%                yp_prime = floor(yp_prime);
%            else
%                yp_prime = ceil(yp_prime);
%            end
       end
       z(1,inx(j))=xp_prime;
       z(2,inx(j))=yp_prime;
   else
      % if n number of points are in area A (where, n>2) 
%       for a=1:size(zu,2)
%           dr(a) = norm(zu(:,a)-zpn);
%       end
      dr = sqrt((xpn-zu(1,:)).^2 + (ypn-zu(2,:)).^2);
      [distr,inx_r] = sort(dr);
      zr = zu(:,inx_r(2)); % because first point is xpn,ypn
      dpr = dr(inx_r(2));
      xr=zr(1);
      yr=zr(2);
      if m==0
          if xpn < xr
              xi = xr - 0.5;
              yi = yc;
          else
              xi = xr + 0.5;
              yi = yc;
          end
          %xi = xr;
          %yi = yc;
      elseif isinf(m)==1
          if ypn < yr
              yi = yr - 0.5;
              xi = xc;
          else
              yi = yr + 0.5;
              xi = xc;
          end
          %xi = xc;
          %yi = yr;
      else
          xi = ((yr + xr/m) - (yc - m*xc))/(m+1/m);
          yi = m*xi + (yc - m*xc);
      end
      clear xp_prime yp_prime
      xp_tmp(1) = floor(xi); yp_tmp(1) = floor(yi);
      xp_tmp(2) = floor(xi); yp_tmp(2) = ceil(yi);
      xp_tmp(3) = ceil(xi); yp_tmp(3) = floor(yi);
      xp_tmp(4) = ceil(xi); yp_tmp(4) = ceil(yi);
      Cond=[];
      for cnd=1:4
          if xr==xp_tmp(cnd) & yr==yp_tmp(cnd)
              Cond = [Cond,cnd];
          end
      end
      TotalCnd=1:4;
      if length(Cond)>0
          Y=TotalCnd~=Cond(1);
          if length(Cond)>1
              for cnd=1:length(Cond)
                  Y=and(Y,TotalCnd~=Cond(cnd));
              end    
          end
      LeftCond = TotalCnd(Y);
      else
          LeftCond=1:4; %no overlap
      end
      if length(LeftCond)>0 & length(LeftCond)<=4
          %i.e. some locations overlap with (xr,yr) when LeftCond >0 & LeftCond <4
          % and no overlap when LeftCond ==4
          dpi = sqrt((xpn-xp_tmp(LeftCond)).^2 + (ypn-yp_tmp(LeftCond)).^2);
          inx_dpi = dpi<dpr;
          if sum(inx_dpi)==0
              dcp=sqrt((xc-xp_tmp(LeftCond)).^2 + (yc-yp_tmp(LeftCond)).^2); 
              [row,inx_cp]=min(dcp);
              inx_cp=LeftCond(inx_cp);
              xp_prime = xp_tmp(inx_cp);
              yp_prime = yp_tmp(inx_cp);              
          else
              dist = dpi(inx_dpi);
              inx_dpi = LeftCond(inx_dpi);
              [row,col]=max(dist);
              inx_dpi = inx_dpi(col);
              xp_prime = xp_tmp(inx_dpi);
              yp_prime = yp_tmp(inx_dpi);
          end
      elseif length(LeftCond)==0
          %i.e. all locations overlap with (xr,yr)
          if m==0
               if xpn < xi
                   xp_prime = xi - 0.5;
                   yp_prime = yi;
               else
                   xp_prime = xi + 0.5;
                   yp_prime = yi;
               end
          elseif isinf(m)==1
              if ypn < yi
                   yp_prime = yi - 0.5;
                   xp_prime = xi;
              else
                   yp_prime = yi + 0.5;
                   xp_prime = xi;
              end
          else
               if xpn < xi
                   xp_prime = xi - 0.5;
                   yp_prime = m*xp_prime + (yc - m*xc);
               else
                   xp_prime = xi + 0.5;
                   yp_prime = m*xp_prime + (yc - m*xc);
               end
          end
          if xpn < xi
              xp_prime = floor(xp_prime);
          else
              xp_prime = ceil(xp_prime);
          end
          if ypn < yi
              yp_prime = floor(yp_prime);
          else
              yp_prime = ceil(yp_prime);
          end
%       elseif length(LeftCond)==4
%           %i.e. no location overlap with (xr,yr)
%           for cnd=1:4
%             dpi(cnd)=sqrt((xpn-xp_tmp(cnd))^2 + (ypn-yp_tmp(cnd))^2); 
%                     % 1) floor(xi), floor(yi)
%                     % 2) floor(xi), ceil(yi)
%                     % 3) ceil(xi), floor(yi)
%                     % 4) ceil(xi), ceil(yi)
%           end
%           inx_dpi = dpi < dpr;
%           dist = dpi(inx_dpi);
%           inx_dpi = LeftCond(inx_dpi);      
%           [row,col] = max(dist);
%           inx_dpi = inx_dpi(col);
%           xp_prime = xp_tmp(inx_dpi);
%           yp_prime = yp_tmp(inx_dpi);
      end
      clear dpi dr
      z(1,inx(j))=xp_prime;
      z(2,inx(j))=yp_prime;
   end
   if FIG==1
   % remove later
   if N<200
       X(xpn,-ypn)=1;
       X(xp_prime,-yp_prime)=0;
       hold on;
       %X=ones(N);
       %idx=sub2ind(size(X),z(1,:),-z(2,:));
       %X(idx)=0;
       imagesc(X'); %grid on;
       %pause(0.1);
       F(im_cnt)=getframe(gcf);
       drawnow
       im_cnt=im_cnt+1;
   else
       if disp_cnt==1
            disp('Pixel size is very large');
            disp_cnt=disp_cnt+1;
       end
   end
   % ############
   end
end
xps=z(1,:);
yps=-z(2,:);
As=abs(max(xps)-min(xps))+1;
Bs=abs(max(yps)-min(yps))+1;

%zoomed
xps = xps - (max(xps)-As);
yps = yps - (max(yps)-Bs);


if As<350 & Bs<350
%if FIG==1
Y=ones(As,Bs);
idy=sub2ind(size(Y),xps,yps);
Y(idy)=0;
figure;  imagesc(Y'); grid on;
%end
end

if exist('A')==1 & exist('B')==1
    if (As>=A & Bs>B) | (As>A & Bs>=B)
        yps=-yps;
        A=A-1;
        B=B-1;
        xps = round(1+(A*(xps-min(xps))/(max(xps)-min(xps))));
        yps = round(1+(-B)*(yps-max(yps))/(max(yps)-min(yps)));
        As=max(xps);
        Bs=max(yps);
        
        Z=ones(As,Bs);
        idz=sub2ind(size(Z),xps,yps);
        Z(idz)=0;
        figure;imagesc(Z'); grid on;
    elseif As>A | Bs>B %This IF statement added on 31-Oct-2019
        yps=-yps;
        A=A-1;
        B=B-1;
        xps = round(1+(A*(xps-min(xps))/(max(xps)-min(xps))));
        yps = round(1+(-B)*(yps-max(yps))/(max(yps)-min(yps)));
        As=max(xps);
        Bs=max(yps);
        
        Z=ones(As,Bs);
        idz=sub2ind(size(Z),xps,yps);
        Z(idz)=0;
        figure;imagesc(Z'); grid on;
    end %#### newly added
end

% % Rotate axis using Convec-Hull algorithm
% yps = -yps;
% % should have a nearly square bounding rectangle
% [xrect,yrect] = minboundrect(xps,yps);
% 
% 
% %gradient (m) of a line y=mx+c
% grad = (yrect(2)-yrect(1))/(xrect(2)-xrect(1));
% theta = atan(grad);
% 
% %Rotation matrix
% %theta=180-theta
% R=[cos(theta) sin(theta);-sin(theta) cos(theta)];
% 
% % rotated rectangle
% zrect = R*[xrect';yrect'];
% 
% % rotated data
% z = R*[xps;yps];
% z=z';
% 
% zUp=round(z);
% zr=size(unique(zUp,'rows'));
% zUp=floor(z);
% zf=size(unique(zUp,'rows'));
% zUp=ceil(z);
% zc=size(unique(zUp,'rows'));
% clear zUp
% if zr(1)==size(z,1)
%     z=round(z);
%     z=(unique(z,'rows'));
%     xps=z(:,1);
%     yps=-z(:,2);
%     As=abs(max(xps)-min(xps))+1;
%     Bs=abs(max(yps)-min(yps))+1;
%     xps = xps - (max(xps)-As);
%     yps = yps - (max(yps)-Bs);
% elseif zf(1)==size(z,1)
%     z=floor(z);
%     z=(unique(z,'rows'));
%     xps=z(:,1);
%     yps=-z(:,2);
%     As=abs(max(xps)-min(xps))+1;
%     Bs=abs(max(yps)-min(yps))+1;
%     xps = xps - (max(xps)-As);
%     yps = yps - (max(yps)-Bs);
% elseif zc(1)==size(z,1)
%     z=ceil(z);
%     z=(unique(z,'rows'));
%     xps=z(:,1);
%     yps=-z(:,2);
%     As=abs(max(xps)-min(xps))+1;
%     Bs=abs(max(yps)-min(yps))+1;
%     xps = xps - (max(xps)-As);
%     yps = yps - (max(yps)-Bs);
% end
% 
% Z=ones(As,Bs);
% idz=sub2ind(size(Z),xps,yps);
% Z(idz)=0;
% figure; imagesc(Z'); grid on;



if FIG==1
%video
writerObj = VideoWriter('SnowFall_Video.avi');
writerObj.FrameRate = 10;
open(writerObj);
% write the frames to the video
for i=1:length(F)
    % convert the image to a frame
    frame = F(i) ;    
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);
end
