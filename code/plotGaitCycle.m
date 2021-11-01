function plotGaitCycle(idxMkrs, m_cols, fs, t, MPP, minDist)
% Plot the gait circle over the functions f.
%
% As fs yuo can use for example:
%    - the TT2 y marker
%    - the stability

    arguments
        idxMkrs
        % Matrix containig the data of the markers at time i
        m_cols (:, :) {}
        % Functions to plot (y axis)
        fs (:, :) {}
        % Time in functions (x axis)
        t (1, :) {}
        % (OPTIONAL) MinPeakProminence parameter
        MPP {mustBePositive} = 40
        % (OPTIONAL) Min Distance parameter
        minDist {mustBePositive} = 0.2
    end
    
    time = m_cols(:,2);

    RTT2 = m_cols(:, idxMkrs.RTT2+1);
    LTT2 = m_cols(:, idxMkrs.LTT2+1);

    r_max = findpeaks(RTT2, 'MinPeakProminence', MPP); %local max right foot
    l_max = findpeaks(LTT2, 'MinPeakProminence', MPP); %local max left foot
    for i = 1:length(r_max)
        r_maxidx(i) = find(RTT2==r_max(i)); %Posizione temporale massimi locali piede destro
    end
    for i = 1:length(l_max)
        l_maxidx(i) = find(LTT2==l_max(i)); %Posizione temporale massimi locali piede sinistro
    end
    [xi, ~] = polyxpoly(time, RTT2, time, LTT2);
    
    while i<length(xi)-1
       if abs(xi(i)-xi(i+1)) < minDist
           xi(i) = mean([xi(i), xi(i+1)]);
           xi(i+1) = [];
           i = i-1;
       end
       i = i+1;
    end

    figure
    for elem=xi'
        xline(elem,'--k',{'SS'})
    end
    hold on
    for elem=time(r_maxidx)'
        xline(elem,'--r',{'DS r'})
    end
    for elem=time(l_maxidx)'
        xline(elem,'--g',{'DS l'})
    end

    for f=fs
        plot(t,f)
    end
    xlabel('Time(s)')
    ylabel('Y(mm)')
    hold off
end
