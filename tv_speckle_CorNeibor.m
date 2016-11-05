function J=tv_speckle_CorNeibor(I,iter,dt,ep,lam,nu,L,I0,C)
%% Private function: tv (by Guy Gilboa).
%% Total Variation denoising.
%% Example: J=tv(I,iter,dt,ep,lam,I0)
%% Input: I    - image (double array gray level 1-256),
%%        iter - num of iterations,
%%        dt   - time step [0.2],
%%        ep   - epsilon (of gradient regularization) [1],
%%        lam  - fidelity term lambda [0],
%%        I0   - input (noisy) image [I0=I]
%%       (default values are in [])
%% Output: evolved image

if ~exist('ep')
   ep=1;
end
if ~exist('dt')
   dt=ep/5;  % dt below the CFL bound
end
if ~exist('lam')
   lam=0;
end
if ~exist('I0')
	I0=I;
end
if ~exist('C')
	C=3;
end
[ny,nx]=size(I); ep2=ep^2;

for i=1:iter,  %% do iterations
   % estimate derivatives
   I_x = (I(:,[2:nx nx])-I(:,[1 1:nx-1]))/2;
	I_y = (I([2:ny ny],:)-I([1 1:ny-1],:))/2;
	I_xx = I(:,[2:nx nx])+I(:,[1 1:nx-1])-2*I;
	I_yy = I([2:ny ny],:)+I([1 1:ny-1],:)-2*I;
	Dp = I([2:ny ny],[2:nx nx])+I([1 1:ny-1],[1 1:nx-1]);
	Dm = I([1 1:ny-1],[2:nx nx])+I([2:ny ny],[1 1:nx-1]);
	I_xy = (Dp-Dm)/4;
   % compute flow
   Num = I_xx.*(ep2+I_y.^2)-2*I_x.*I_y.*I_xy+I_yy.*(ep2+I_x.^2);
   Den = (ep2+I_x.^2+I_y.^2).^(3/2);
   I_t = Num./Den + lam.*FiedTerm(I,I0,nu,L,C);
   I=I+dt*I_t;  %% evolve image by dt
end % for i
%% return image
%J=I*Imean/mean(mean(I)); % normalize to original mean
J=I;

function ft=FiedTerm(I,I0,nu,L,W)
ft0=(I0-I)./(I.^2+eps);
[Nx,Ny]=size(I);
ft1=zeros(Nx,Ny);
for ii=1:Nx
    for jj=1:Ny
        if ii<(W+1)/2
            idxx=1:ii+(W-1)/2;
        elseif ii>Nx-(W-1)/2
            idxx=ii-(W-1)/2:Nx;
        else
            idxx=ii-(W-1)/2:ii+(W-1)/2;
        end
        if jj<(W+1)/2
            idxy=1:jj+(W-1)/2;
        elseif jj>Ny-(W-1)/2
            idxy=jj-(W-1)/2:Ny;
        else
            idxy=jj-(W-1)/2:jj+(W-1)/2;
        end
        SubImg=I(idxx,idxy);
        ft1(ii,jj)=sum(sum((I0(ii,jj)-SubImg)./(SubImg.^2+eps)));
    end
end
ft=L*ft0+nu.*(ft1-ft0)/(W*W-1);

        