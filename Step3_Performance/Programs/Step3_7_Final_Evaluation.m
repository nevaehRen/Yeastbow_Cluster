% load ../Evaluation/Output.mat

TP = cat(1, Output.TP);
Precision = cat(1, Output.Precision);
Recall = cat(1, Output.Recall);
F1 = cat(1, Output.F1);
FP = cat(1, Output.FP);
FN = cat(1, Output.FN);

close all;
figure;
hold on
set(gcf,'Color',[1 1 1])
set(gcf,'Position',[10  6  600 300], 'color',[1 1 1]);

plot(TP+FP,F1,'k.','markersize',14)
plot(TP+FP,Recall,'r.','markersize',12)
plot(TP+FP,Precision,'b.','markersize',12)

h=legend('F1','Recall','Precision');
set(h,'edgeColor',[.8 .8 .8],'Location','northeast')

set(gca,'FontName','American Typewriter','FontSize',14, 'LineWidth',2)
set(gca, 'YTick', [0:0.2:1]) 
set(gca, 'XTick', [0:20:100]) 
xlim([0 80])
ylim([0 1])

% ylabel('F1')
xlabel('Cell Number')

mean(F1)


