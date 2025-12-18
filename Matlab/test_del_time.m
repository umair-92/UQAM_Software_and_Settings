%dTime = read_bor('Z:\uqam-site\Database\2025\UQAM_1\Flux\co2_time_lag');
%dTime = read_bor('Z:\uqam-site\Database\2025\MCGILL_1\Flux\co2_time_lag');
dTime = read_bor('Z:\uqam-site\Database\2025\UQAM_2\Flux\co2_time_lag');
N=length(dTime);
w_len = 3500;
w_st = 10000;
% w_len = N/2-1;
% w_st = 1;
figure(1);
clf
ax=[];
ax(1)=subplot(2,2,3);
histogram(dTime(w_st:w_st+w_len));
ax(2)=subplot(2,2,4);
histogram(dTime(w_st+w_len:w_st+2*w_len));
subplot(2,1,1);
plot((1:N),dTime,'.', ...
      w_st:w_st+w_len          ,dTime(w_st:w_st+w_len),'.',...
      w_st+w_len:w_st+2*w_len,dTime(w_st+w_len:w_st+2*w_len),'.');

linkaxes(ax)
%zoom on
