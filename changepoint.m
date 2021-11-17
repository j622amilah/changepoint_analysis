%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%changepoint.m = change point analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function earth = changepoint(xin)

% close all
% clear all
% clc

trig = 2;
count = 1;

%x = [Jan87; Feb87; Mar87; Apr87; May87; Jun87; Jul87; Aug87; Sep87; Oct87; Nov87; Dec87; Jan88; Feb88; Mar88; Apr88; May88; Jun88; Jul88; Aug88; Sep88; Oct88; Nov88; Dec88];
earth.x{count, 1} = xin;
%earth.x{count, 1} = [10.7; 13.0; 11.4; 11.5; 12.5; 14.1; 14.8; 14.1; 12.6; 16.0; 11.7; 10.6; 10.0; 11.4; 7.9; 9.5; 8.0; 11.8; 10.5; 11.2; 9.2; 10.1; 10.4; 10.5];
%earth.x{count, 1} = [10.0; 11.4; 7.9; 9.5; 8.0; 11.8; 10.5; 11.2; 9.2; 10.1; 10.4; 10.5; 10.7; 13.0; 11.4; 11.5; 12.5; 14.1; 14.8; 14.1; 12.6; 16.0; 11.7; 10.6];

nc = 0;
levels = 0;

while trig == 2
    %count
    %trig
    [earth.avgCon_level(count, 1), earth.change(count, 1), earth.avgm_MSE(count, 1)] = CP(earth.x{count, 1}, count);
    
    if earth.change(count, 1) == 1
        
        %Split data in half: start with left side
        earth.x{count+1, 1} = earth.x{count, 1}(1:earth.avgm_MSE(count, 1));
        
        levels = 0;
        for u = 1:length(earth.change)
            if earth.change(u, 1) == 1
                levels = levels + 1;
            end
        end
        %levels
        
    else
        
        %nc
        if levels-nc == 0
            trig = 1;
        else
            
            if length(earth.change) == 4
                if earth.change == [1; 0; 1; 0] %#ok<BDSCA>
                    earth.x{count+1, 1} = earth.x{count-1, 1}((earth.avgm_MSE(count-1, 1)+1):length(earth.x{count-1, 1}));
                else
                    earth.x{count+1, 1} = earth.x{levels-nc, 1}((earth.avgm_MSE(levels-nc, 1)+1):length(earth.x{levels-nc, 1}));
                end
            else
                earth.x{count+1, 1} = earth.x{levels-nc, 1}((earth.avgm_MSE(levels-nc, 1)+1):length(earth.x{levels-nc, 1}));
            end
            
        end
        
        nc = nc + 1;
        
    end
    
    count = count + 1;
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [avgCon_level, change, avgm_MSE] = CP(x, count)

figure('Visible','off')
plot(x, 'Linewidth', 2)
% ylabel('Trade Deficit')
% xlabel('Month')
% set(gca, 'XTickLabelMode', 'manual', 'XMinorGrid', 'off', 'XTick', [1 4 7 10 13 16 19 22] ,'XTickLabel', ['Jan87';'Apr87';'Jul87';'Oct87';'Jan88';'Apr88';'Jul88';'Oct88']);
title('Data')
print('-depsc2', '-r300', sprintf('x_count%d', count))

sprintf('CUMSUM_J passed\n')
[x_avg, S, S_min, S_max, S_diff] = CUMSUM_J(x);

sprintf('procedure passed\n')
[Con_level, m_CUMSUM, m_MSE] = procedure(x, S, S_max, S_diff, count);

sprintf('avgm_MSE passed\n')
avgm_MSE = sum(m_MSE)/length(m_MSE);

%Once a change has been detected, the data can be broken into two segments, one each side of the change-point, and the analysis repeated for each segment.  
%For each additional significant change found, continue to split the
%segments in two.  In this manner multiple changes can be detected.

sprintf('sigcheck passed\n')
[avgCon_level, change] = sigcheck(Con_level, avgm_MSE);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x_avg, S, S_min, S_max, S_diff] = CUMSUM_J(x)
%Calculate and plot a cummulative sum based on the data. Let X_{1},
%X_{2}, ..., X_{24} represent the 24 data points.  From this, the
%cumulative sums S_{0}, S_{1},...,S_{24} are calculated

%1: Calculate the average
x_avg = sum(x)./length(x);

%2: Start the cumulative sum at zero by setting S_{0} = 0
S(1,1) = 0;

%3: Calculate the other cumulative sums by adding the difference between
%current value and the average to the previous sum, i.e.,S_{i}=S_{i-1} + (x_{i}-x_avg) for i = 1, 2,...,24
for i = 2:length(x)
    S(i,1) = S(i-1, 1) + (x(i-1,1) - x_avg);
end

% figure('Visible','off')
% plot(S, 'Linewidth', 2)
% ylabel('Cumulative sum of x')
% xlabel('Month')
% set(gca, 'XTickLabelMode', 'manual', 'XMinorGrid', 'off', 'XTick', [1 4 7 10 13 16 19 22] ,'XTickLabel', ['Jan87';'Apr87';'Jul87';'Oct87';'Jan88';'Apr88';'Jul88';'Oct88']);
% title('Cumulative sum')

%Interpreting a CUSUM chart requires some practice.  Suppose that during a period of time the values tend to be above the overall average.  
%Most of the values added to the cumulative sum will be positive and the sum will steadily increase.  A segment of the CUSUM chart with 
%an upward slope indicates a period where the values tend to be above the overall average.  Likewise a segment with a downward slope 
%indicates a period of time where the values tend to be below the overall average.  A sudden change in direction of the CUSUM indicates 
%a sudden shift or change in the average.  Periods where the CUSUM chart follows a relatively straight path indicate a period where 
%the average did not change.

%The problem with CUSUM charts is that they require considerable skill to properly interpret.  
%How can we be sure that these changes took place?  
%A confidence level can be determined for the apparent change by performing a bootstrap analysis.

%4: Calculate an estimator of the magnitude of the change
S_min = min(S);
S_max = max(S);
S_diff = S_max - S_min;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Con_level, m_CUMSUM, m_MSE] = procedure(x, S, S_max, S_diff, count)

for j = 1:10    %Repeat this bootstraping analysis 10 times to see if it is consistant
    %5: Bootstrap analysis
    %a: Generate a bootstrap sample of 24 units, denoted x^{0}_{1}, x^{0}_{2},..., x^{0}_{24}, by randomly reordering the original 24 values.
    %This is called sampling without replacement.

    N = 1000;  %N = the number of bootstrap samples performed

    figure('Visible','off')
    plot(S, 'k', 'Linewidth', 2)

    for i  = 1:N
        x_boot_order = randperm(length(x));

        for k = 1:length(x)
            x_boot{i,1}(k,1) = x(x_boot_order(k), 1);
        end

        [x_avg_boot(i,1), S_boot{i,1}, S_min_boot(i,1), S_max_boot(i,1), S_diff_boot(i,1)] = CUMSUM_J(x_boot{i,1});
        hold on
        plot(S_boot{i,1}, 'Linewidth', 2)
    end

    ylabel('Cumulative sum of x')
    xlabel('Month')
    %set(gca, 'XTickLabelMode', 'manual', 'XMinorGrid', 'off', 'XTick', [1 4 7 10 13 16 19 22] ,'XTickLabel', ['Jan87';'Apr87';'Jul87';'Oct87';'Jan88';'Apr88';'Jul88';'Oct88']);
    title('Cumulative sum of original and bootstraps')
    print('-depsc2', '-r300', sprintf('cumsum_count%d_boot%d', count, j))

    %A bootstrap analysis consists of performing a large number of bootstraps and counting the number of bootstraps for which S_diff_boot < S_diff.
    %Let N be the number of bootstrap samples performed and let X be the number of bootstraps for which S_diff_boot < S_diff.  
    X = 0;
    for i = 1:N
        if S_diff_boot(i,1) < S_diff
            X = X + 1;  %X = the number of bootstraps for which S_diff# < S_diff
        end
    end
    
    Con_level(j,1) = 100*(X/N);  %Confidence level that a change occured as a percentage

    %Typically 90%, or 95% confidence is required before one states that a significant change has been detected.

    %Ideally, rather than bootstrapping, one would like to determine the distribution of S_diff# based on all possible reorderings of the data.
    %However, this is generally not feasible.  The trade deficit data consists of 24 values.  The total number of possible reorderings is 24! = 6.2 1023.  
    %This is more samples than could reasonably be generated.  The bootstrap analysis randomly selected 1000 of these possible reorderings and used them 
    %to estimate the distribution of S0diff.  A better estimate can be obtained by increasing the number of bootstrap samples.  However, 1000 bootstraps 
    %is sufficient for most purposes.  Repeating the above analysis 10 times resulted in the following confidence levels: 
    %99.6%, 99.2%, 99.3%, 99.2%, 99.4%, 99.7%, 99.2%, 99.7%, 99.5% and 99.2%.  All the analysis performed in this article are based on 1,000 bootstrap samples.

    S_diff_all = [S_diff; S_diff_boot];

    figure('Visible','off')
    hist(S_diff_all)
    xlabel('S\_diff')
    ylabel('Number of bootstraps')
    title('Distribution of S\_diff for all bootstrap samples')
    print('-depsc2', '-r300', sprintf('Hist_bootstrap_count%d', count))

    %6: First estimator of when the change occured (m)
    %Once a change has been detected, an estimate of when the change occured can be made.  Once such estimator is the CUMSUM estimator.
    Sm = S_max;        %#ok<NASGU> %Sm = the point furthest from zeros in the CUMSUM chart

    for i = 1:length(S)
        if S(i,1) == S_max
            m = i;  %m = the last point before the change occurred, the point m+1 estimates the first point after the change
        end
    end
    m_CUMSUM(j,1) = m;

    %7: Second estimator of when the change occured is the mean square error
    %(MSE) estimator.  The value of m that minimizes MSE(m) is the best
    %estimator of the last point before the change.
    for m = 1:length(x)
        x_avg1 = sum(x(1:m))/m;

        x_avg2 = sum(x(m+1:length(x)))/(length(x) - m);

        MSE_m(m,1) = sum((x(1:m) - x_avg1).^2) + sum((x(m+1:length(x)) - x_avg2).^2);
    end

    for i = 1:length(x)
        if MSE_m(i,1) == min(MSE_m)
            m_MSE(j,1) = i;  %The value of m minimizing MSE(m)
        end
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [avgCon_level, change] = sigcheck(Con_level, m_MSE)

avgCon_level = sum(Con_level)/length(Con_level);
if avgCon_level > 90
    sprintf('Change detected: datapoint = %d\n', m_MSE)
    change = 1;
else
    sprintf('No change detected\n')
    change = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%