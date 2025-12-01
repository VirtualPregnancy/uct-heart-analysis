% This script infills the SAM mask every 5 images
% There are full torso and arm segmentations and just arm segmentations

% The size of the images themselves
Ni = 2248; % y axis length
Nj = 2520; % x axis length
%Nk = length(400:1650); beginning and end points of the stack
Nk = length(0768:1318);

%IR = [400:50:1650]; % original range
IR = [0768:25:1318]; % additional masks on apex of heart
%II = [1:50:Nk];
II = [1:25:Nk];
IM = false(Ni,Nj,Nk);
%FL = 400:1650;
FL = 0768:1318;

fprintf('Loading masks\n'); % Load every 25th mask
for k=1:length(IR)
    IM(:,:,II(k)) = imread(sprintf('/eresearch/murine-fgr-microct-study/zcol533/intermediate/2024-marsden-heart/uct/HY3F7-E18.5/HY3F7-E18.5H/Masks/ContrastPoolMasks/Segmentations/HY3F7BW0000%04d.png',IR(k)));
    %IM(:,:,II(k)) = imread(sprintf('../PoolMask/C4F8_%04d_CPoolMask.png',IR(k)));
end

% Mask infill to all slices
fprintf('Morphing masks\n');
for k=1:length(II)-1
    I1 = IM(:,:,II(k));
    I2 = IM(:,:,II(k+1));
    for j=II(k):II(k+1)
        IM(:,:,j) = SimpleMaskMorph(I1,I2,II(k),II(k+1),j);
    end
end

% Write masks to file
fprintf('Writing masks\n');
for k=1:Nk
    imwrite(IM(:,:,k),sprintf('/eresearch/murine-fgr-microct-study/zcol533/intermediate/2024-marsden-heart/uct/HY3F7-E18.5/HY3F7-E18.5H/Masks/ContrastPoolMasks/InfilledMask/HY3F7BW0000%04d.png',FL(k)));
    %imwrite(IM(:,:,k),sprintf('../InFillPoolMask/C4F8_%04d_CPoolMaskInfill.png',FL(k)));
end;


% Apply mask to full image
fprintf('Applying masks\n');
for k=1:Nk
  I = imread(sprintf('/eresearch/murine-fgr-microct-study/zcol533/primary/2024-marsden-heart/uct/HY3F7-E18.5/HY3F7-E18.5H/HY3F7-E18.5H-images/HY3F7 heart dry__IR_rec0000%04d.png',FL(k)));
  I = uint8(repmat(~IM(:,:,k),[1,1,3])).*I;
  imwrite(I,sprintf('/eresearch/murine-fgr-microct-study/zcol533/derivative/2024-marsden-heart/uct/HY3F7-E18.5/HY3F7-E18.5H/Masks/ContrastPoolMasks/MaskRemovedImages/HY3F7 heart dry__IR_rec0000%04d.png',FL(k)));
end
