clearvars; close all;
fclose(instrfind);
s = serial('COM9');
% set(s, 'FlowControl', 'none');
% set(s, 'BaudRate', 9600);
set(s, 'BaudRate', 38400);
% set(s, 'BaudRate', 115200);
% set(s, 'Parity', 'none');
% set(s, 'DataBits', 8);
% set(s, 'StopBit', 1);
% s.InputBufferSize = 64;

nData = 3;
nFluf = 0;
nWin = 10000;
x = [];
time = [];
%% Setup plotting
figure; hold on;
load matlabcolors.mat;
subplot(1,2,1); hold on;
for ii = 1:nData
    h{ii} = plot(0,0);
end
legend('Yaw','Pitch','Roll');
xlabel('Time (s)');
ylabel('Data (units)');
axis auto;
grid on;

subplot(1,2,2); hold on;
ne = 20;
[X,Y,Z] = ellipsoid(0,0,0,1,0.5,0.25,ne-1);
hellipsoid = surf(X,Y,Z);
axis([-1 1 -1 1 -1 1]);
view(45,45);
% axis image;
fopen(s);
tic;
i =0;

while toc<30
    i = i+1;
    
    newx = [];
    newt = [];
    if s.BytesAvailable
        %         i2 = 0;
        %         while s.BytesAvailable>256
        a=fscanf(s); % what is vomited by arduino
        %             a = fscanf(s); % do it twice cuz the first one might be incomplete
        %     tnow = toc;
        d=str2num(a)'; % parse it into data
        l = length(d);
        if l~=(nData+nFluf)
            d = nan(nData+nFluf,1);
        end
        %     if length(x)>nWin
        %         for i=2:nWin+1
        %             x(:,i-1)=x(:,i);
        %             time(i-1)=time(i);
        %         end
        %         x(:,nWin+1)=d;
        %         time(nWin+1) = tnow;
        %         i=2;
        %     else
        %             newx = [newx d];
        %             newt = [newt toc];
        %         i2 = i2+1;
        %         end
        %     disp('madeit');
        x=[x d];
        time = [time toc];
        %         x=[x newx];
        %         time = [time newt];
        %     end
        %     h1.XData = time; h1.YData = x(1,:);
        %     h2.XData = time; h2.YData = x(2,:);
        %     addpoints(h1,d(2),d(3));
        %     addpoints(h2,d(2),d(4));
        for ii = 1:nData
            h{ii}.XData = time; 
            h{ii}.YData = x(ii,:);
            %             addpoints(h{ii},newt,newx(ii,:));
        end
        %         addpoints(h1,newt,newx(1,:));
        %         addpoints(h2,newt,newx(2,:))
        %         addpoints(h3,newt,newx(3,:))
        
        
    end
    if ~isempty(x)
    yaw = x(1,end); pitch = x(2,end); roll = x(3,end);
    R = eul2rotm(pi/180*[yaw,pitch,roll]);
    XYZR = R*[X(:)';Y(:)';Z(:)'];
    XR = reshape(XYZR(1,:),ne,ne);
    YR = reshape(XYZR(2,:),ne,ne);
    ZR = reshape(XYZR(3,:),ne,ne);
    hellipsoid.XData = XR;
    hellipsoid.YData = YR;
    hellipsoid.ZData = ZR;
%     rotate(hellipsoid,[1,0,0],(roll-0)*180/pi)
%     rotate(hellipsoid,[0,1,0],(pitch-0)*180/pi)
%     rotate(hellipsoid,[0,0,1],(yaw-0)*180/pi+90)
    end
    drawnow limitrate;
    %             flushinput(s); % throw out what is in there so we get the latest stuff
    %             pause(0.1);
end
fclose(s);