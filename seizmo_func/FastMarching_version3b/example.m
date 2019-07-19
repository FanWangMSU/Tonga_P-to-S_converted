clc;
clear;
SourcePoint = [51; 51];
SpeedImage = 12*ones([101 101]);
[X Y] = ndgrid(1:101, 1:101);
T1 = sqrt((X-SourcePoint(1)).^2 + (Y-SourcePoint(2)).^2)/12;

% Run fast marching 1th order, 1th order multi stencil 
% and 2th orde and 2th orde multi stencil

tic; T1_FMM1 = msfm(SpeedImage, SourcePoint, false, false); toc;
tic; T1_MSFM1 = msfm(SpeedImage, SourcePoint, false, true); toc;
tic; T1_FMM2 = msfm(SpeedImage, SourcePoint, true, false); toc;
tic; T1_MSFM2 = msfm(SpeedImage, SourcePoint, true, true); toc;

% Show results
fprintf('\nResults with T1 (Matlab)\n');
fprintf('Method   L1        L2        Linf\n');
Results = cellfun(@(x)([mean(abs(T1(:)-x(:))) mean((T1(:)-x(:)).^2) max(abs(T1(:)-x(:)))]), {T1_FMM1(:) T1_MSFM1(:) T1_FMM2(:) T1_MSFM2(:)}, 'UniformOutput',false);
fprintf('FMM1:   %9.5f %9.5f %9.5f\n', Results{1}(1), Results{1}(2), Results{1}(3));
fprintf('MSFM1:  %9.5f %9.5f %9.5f\n', Results{2}(1), Results{2}(2), Results{2}(3));
fprintf('FMM2:   %9.5f %9.5f %9.5f\n', Results{3}(1), Results{3}(2), Results{3}(3));
fprintf('MSFM2:  %9.5f %9.5f %9.5f\n', Results{4}(1), Results{4}(2), Results{4}(3));