classdef motData
% This class manage the steps in the *.mot file.
% This class can filter and plot the force, point of pressure and moment of a step

    properties (Access = private)
        time;
        
        force;
        point;
        moment;
        
        fforce;
        fpoint;
        fmoment;
    end
    
    methods
        % Constructor
        function obj = motData(time, force, point, moment)
            obj.time = time;
            
            obj.force = force;
            obj.point = point;
            obj.moment = moment;
            
            % FILTERING PARAMETERS
            grade = 4; % grade
            fc = 15; % cutoff frequency
            fsm = 200; % sampling frequency
            [b,a] = butter(grade, fc/(fsm/2));
            % END
            
            obj.fforce = filtfilt(b, a, force);
            obj.fpoint = filtfilt(b, a, point);
            obj.fmoment = filtfilt(b, a, moment);
        end
        
        function pltAll(obj)
            obj.pltForce();
            obj.pltPoint();
            obj.pltMoment();
        end
        
        function pltForce(obj)
            figure('NumberTitle', 'off', 'Name', 'Force')
            
            subplot(3, 1, 1)
            hold on
            plot(obj.time, obj.force(:, 1), 'Color','red');
            plot(obj.time, obj.fforce(:, 1), 'Color','blue');
            hold off
            title('Force X')
            
            subplot(3, 1, 2)
            hold on
            plot(obj.time, obj.force(:, 2),'Color','red');
            plot(obj.time, obj.fforce(:, 2), 'Color','blue');
            hold off
            title('Force Y')
            
            subplot(3, 1, 3)
            hold on
            plot(obj.time, obj.force(:, 3),'Color','red');
            plot(obj.time, obj.fforce(:, 3), 'Color','blue');
            hold off
            title('Force Z')
            
            sgtitle('Force')
        end
        
        function pltPoint(obj)
            figure('NumberTitle', 'off', 'Name', 'Point of Pressure')
            
            subplot(3,2,1)
            hold on
            plot(obj.time, obj.point(:, 1),'Color','red');
            plot(obj.time, obj.fpoint(:, 1), 'Color','blue');
            hold off
            title('Point X')
            
            subplot(3,2,3)
            hold on
            plot(obj.time, obj.point(:, 2),'Color','red');
            plot(obj.time, obj.fpoint(:, 2), 'Color','blue');
            hold off
            title('Point Y')
            
            subplot(3,2,5)
            hold on
            plot(obj.time, obj.point(:, 3),'Color','red');
            plot(obj.time, obj.fpoint(:, 3), 'Color','blue');
            hold off
            title('Point Z')

            subplot(3,2,[2, 4, 6])
            hold on
            plot3(obj.point(:, 1),obj.point(:, 2),obj.point(:, 3),'Color','red');
            plot3(obj.fpoint(:, 1),obj.fpoint(:, 2),obj.fpoint(:, 3), 'Color','blue');
            hold off
            title('Force X')
            
            sgtitle('Point of Pressure')
        end
        
        function pltMoment(obj)
            figure('NumberTitle', 'off', 'Name', 'Moment')
            
            subplot(3,1,1)
            hold on
            plot(obj.time, obj.moment(:, 1),'Color','red');
            plot(obj.time, obj.fmoment(:, 1), 'Color','blue');
            hold off
            title('Moment X')
            
            subplot(3,1,2)
            hold on
            plot(obj.time, obj.moment(:, 2),'Color','red');
            plot(obj.time, obj.fmoment(:, 2), 'Color','blue');
            hold off
            title('Moment Y')
            
            subplot(3,1,3)
            hold on
            plot(obj.time, obj.moment(:, 3),'Color','red');
            plot(obj.time, obj.fmoment(:, 3), 'Color','blue');
            hold off
            title('Moment Z')
            
            sgtitle('Moment')
        end
        
        function force = getForce(obj)
            force = obj.force;
        end
        function point = getPointOfPressure(obj)
            point = obj.point;
        end
        function moment = getMoment(obj)
            moment = obj.moment;
        end
        
        function force = getFilteredForce(obj)
            force = obj.fforce;
        end
        function point = getFilteredPointOfPressure(obj)
            point = obj.fpoint;
        end
        function moment = getFilteredMoment(obj)
            moment = obj.fmoment;
        end
    end
end


