clear
clc
close all
C = jet;
j =6; % for colors

load results_4_21
H = result.fval;
N = 10;

t = 1;
for n=1:N
    r(:,n) = t:t+2;
    t = t + 3;
    
    h = bar(r(:,n), H(n,:));
    col = C(n*j,:);
    set(h, 'FaceColor', col)
    if n~=N
        hold on
    end
end
set(gca, 'XTickLabel', '')
ylim([0 3.2*10^5]); 
xlim([0 40]);
ylabel('Objective Function Value');
set(gca,'FontSize',18,'fontWeight','bold')
set(findall(gcf,'type','text'),'FontSize',22,'fontWeight','bold')
xlabel('Different Initial Populations');
title('Optimal Function Values Using Genetic Algorithms')
grid;
func = 0;
for n = 1:3
    for g = 1:10
        func = func + result.output(g,n).funccount;
    end
end
func
    
    leg{n} = strcat('pop = ',num2str(80+10*n),' & gen = ', num2str(40+5*n));
end
    legend(leg{1:n})

    for n = 1:10