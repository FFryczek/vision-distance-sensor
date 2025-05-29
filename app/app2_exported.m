classdef app2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        AmountTextArea              matlab.ui.control.TextArea
        AmountTextAreaLabel         matlab.ui.control.Label
        DistanceYTextArea           matlab.ui.control.TextArea
        DistanceYTextAreaLabel      matlab.ui.control.Label
        DistanceXTextArea           matlab.ui.control.TextArea
        DistanceXTextAreaLabel      matlab.ui.control.Label
        TimeDurationEditFieldLabel  matlab.ui.control.Label
        TimeDurationEditField       matlab.ui.control.NumericEditField
        StartButton                 matlab.ui.control.Button
        UIAxes                      matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        cam  % IP camera image
        N % number of seconds to run
         % serial port definition
        amm
        am
        Dx % distance in x
        Dy % distance in y
       

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
             %Initialize camera and serial port
   
            app.cam = webcam('iPhone (Filip 13) Camera');
           %Reading value for duration
            app.N = app.TimeDurationEditField.Value;
           %Initializing live preview
           %preview(app.cam);
           %Initializing n
           n = 0;
           app.am = 0;
           %Initalizing for fft
           fs = 200;
           dt = 1/fs;
        


           %Capturing and processing image loop
            while n < app.N
                app.am = 0;
                img = snapshot(app.cam);
                imshow(img, 'Parent', app.UIAxes);
                
                % Convert to grayscale and adjust
                img_b = img(:,:,3); %blue
                img_b = imadjust(img_b);
               % img_b = (1*log(1+img_b));
                
                % IMAGE PROCESSING
                bbox2 = [];
                se1 = strel("square", 10);  % Mask 1
                se2 = strel("disk", 3);     % Mask 2
                
                % Level of binarization (adjust according to environment)
                level_b = 210/255;
                
                bin1 = imbinarize(img_b, level_b);
                %bin1 = not(bin1);
                bin1 = imclose(bin1, se1);
                bin1 = imdilate(bin1, se2);
                
                
                % Bounding box
                bbox = regionprops(bin1, "BoundingBox", "FilledArea");
                
                % Plotting
                hold(app.UIAxes, 'on');
                for k = 1:length(bbox)
                    p = bbox(k).FilledArea;
                    if p > 100
                        app.am = app.am+1;
                        bbox2 = [bbox2; bbox(k, 1)];
                        BB = bbox(k).BoundingBox;
                        rectangle(app.UIAxes, "Position", [BB(1), BB(2), BB(3), BB(4)], ...
                                  "LineWidth", 1, "EdgeColor", "r");
                    end
                end
                hold(app.UIAxes, 'off');




               
 %Calculating distance
                if length(bbox2) >= 2
                    a = [bbox2(1).BoundingBox];
                    b = [bbox2(2).BoundingBox];
                    pixh = b(4); % height of cup in pixels (real world diameter 5cm)
                    ratio = 5 / pixh;  % ratio of cm to pixels

                % Distance between two cups
                    app.Dx = (b(1) + (b(3))/2 - (a(1) + (a(3))/2)) * ratio; % real distance between centres
                    app.Dy = (b(2) + (b(4))/2 - (a(2) + (a(4))/2)) * ratio; % calculating real distance
                    
                    hold(app.UIAxes, 'on');
                    title(app.UIAxes, [num2str(abs(app.Dx)), " cm in x   ", num2str(abs(app.Dy)), " cm in y"]);
                    hold(app.UIAxes, 'off');
                    DX = num2str(abs(app.Dx));
                    DY = num2str(abs(app.Dy));
                    app.DistanceXTextArea.Value = DX;
                    app.DistanceYTextArea.Value = DY;

                % Sending distance
                %write(app.s,DX,"uint8")

                % FFT for the sake of it
                %{
                sig = app.Dx * cos * (2*pi*app.Dy*t);

                ft = fft(signal);
                m = length(signal);
                fv = (0:m-1)*(fs/m);
                
                hold(app.UIAxes2, 'on');
                plot(app.UIAxes2, fv,ft);
                xlabel(app.UIAxes2, "Distance in Y");
                ylabel(app.UIAxes2, "Distance in X");
                 
                %}

          
                pause(1);
                n = n+1;
                else
                    pause(1);
                    n = n+1;
            end 
                   %send how many u see
               app.amm = num2str(app.am);
              %  ma = num2str(app.am);
                app.AmountTextArea.Value = app.amm;
            end
            pause (2);
                        akk = app.am;
            s = serialport("/dev/tty.wchusbserial110", 115200);  
            write(s,akk,"uint8");
            
        end

        % Callback function
        function SendAmountButtonPushed(app, event)

        
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 813 602];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'IMAGE')
            app.UIAxes.Position = [49 70 507 483];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [686 23 100 23];
            app.StartButton.Text = 'Start';

            % Create TimeDurationEditField
            app.TimeDurationEditField = uieditfield(app.UIFigure, 'numeric');
            app.TimeDurationEditField.Position = [686 565 100 22];

            % Create TimeDurationEditFieldLabel
            app.TimeDurationEditFieldLabel = uilabel(app.UIFigure);
            app.TimeDurationEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeDurationEditFieldLabel.Position = [591 565 80 22];
            app.TimeDurationEditFieldLabel.Text = 'Time Duration';

            % Create DistanceXTextAreaLabel
            app.DistanceXTextAreaLabel = uilabel(app.UIFigure);
            app.DistanceXTextAreaLabel.HorizontalAlignment = 'right';
            app.DistanceXTextAreaLabel.Position = [555 480 66 22];
            app.DistanceXTextAreaLabel.Text = 'Distance X:';

            % Create DistanceXTextArea
            app.DistanceXTextArea = uitextarea(app.UIFigure);
            app.DistanceXTextArea.Interruptible = 'off';
            app.DistanceXTextArea.Editable = 'off';
            app.DistanceXTextArea.Position = [636 481 150 23];

            % Create DistanceYTextAreaLabel
            app.DistanceYTextAreaLabel = uilabel(app.UIFigure);
            app.DistanceYTextAreaLabel.HorizontalAlignment = 'right';
            app.DistanceYTextAreaLabel.Position = [555 446 65 22];
            app.DistanceYTextAreaLabel.Text = 'Distance Y:';

            % Create DistanceYTextArea
            app.DistanceYTextArea = uitextarea(app.UIFigure);
            app.DistanceYTextArea.Editable = 'off';
            app.DistanceYTextArea.Position = [635 444 151 26];

            % Create AmountTextAreaLabel
            app.AmountTextAreaLabel = uilabel(app.UIFigure);
            app.AmountTextAreaLabel.HorizontalAlignment = 'right';
            app.AmountTextAreaLabel.Position = [574 411 47 22];
            app.AmountTextAreaLabel.Text = 'Amount';

            % Create AmountTextArea
            app.AmountTextArea = uitextarea(app.UIFigure);
            app.AmountTextArea.Position = [636 408 150 27];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app2_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end