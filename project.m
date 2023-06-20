close all;
%Initialization....................................................

N=100;
%InterArrival Time Array : Random Generation
InterArrival = zeros(1,N);
for i=1:N
    InterArrival(1,i)=int32((5-1)*rand(1,1) + 1);
end

%Total Departments
Departments = ["Cardiology" "ENT" "Neurology" "Orthopedics" "Physiotherapy" "Ophthalmology" "Oncology" "Gynecology" "Orthodontics" "Pediatrics"];

%Num of Beds of Departments
NumBeds = zeros(1,10);
for i=1:10
    NumBeds(1,i) = int32(9*rand(1,1)+1);
end

TotalBeds=NumBeds;
for i=1:10
    %disp(TotalBeds(i));
end

%Respective Charges of Deptartments
Charge = zeros(1,10);
for i=1:10
    Charge(1,i) = int32((1000-200)*rand(1,1)+200);
end
%will store the revenue collected by each dept
TotalRevenue = zeros(1,10);

%each patient's department is decided here
WhichDept = zeros(1,N);
for i=1:N
    WhichDept(1,i)=int32((10-1)*rand(1,1) + 1);
end

%Emergency Patient (15% chance that a patient is in emergency situation
isCritical = zeros(1,N);
for i=1:N
    x=rand(1,1);
   if(x>=0 && x<=0.15)
      isCritical(1,i)=1;
   else 
      isCritical(1,i)=0;
   end
end

%Time taken by each patient
TimeTaken = zeros(1,N);
for i=1:N
    TimeTaken(1,i)=int32((900-1)*rand(1,1) + 1);
end


%Calculating Time of Arrival
TimeOfArrival = zeros(1,N);
TimeOfArrival(1,1)=1;
for i=2:N
    TimeOfArrival(1,i) = TimeOfArrival(1,i-1) + InterArrival(1,i);
    %disp(TimeOfArrival(i));
end
TotalTime = TimeOfArrival(1,N);
%X = ["TotalTime : "," : ", num2str(TotalTime)];
%disp(X);
WaitingTime = zeros(1,N);

%No of emergency wards
NoOfWards = 10;
EmergencyWards=NoOfWards;

%charge of emergency ward
ChargeEW = 1000;

%revenue of emergency ward
RevenueEW = 0;

%time to empty the bed in emergency ward
TimeEW = zeros(1,NoOfWards);


%time to empty the bed in departments
TimeDept=zeros(10,10);


ReferedPatients=0;


WaitDept = zeros(1,10);
k=1;
i=0;
count =0;


PatientWaitDeptwise = zeros(1,10);
TotalPatientDept = zeros(1,10);

ServiceTimeDept = zeros(1,10);
%Driver Code.........................................................

while k<=N
    i=i+1;
    %----------- MANAGE EMERGENCY WARD ----------------
   
    if(isCritical(1,k)==1)
        for j=1:NoOfWards
            if(TimeEW(1,j)<=i && TimeEW(1,j)~=0)
                EmergencyWards = EmergencyWards + 1;
                TimeEW(1,j)=0;
            end
        end

        if(EmergencyWards > 0  && TimeOfArrival(1,k)<=i)
            EmergencyWards = EmergencyWards - 1;
            for b=1:NoOfWards
                if(TimeEW(1,b)==0)
                    TimeEW(1,b) = i + TimeTaken(1,k);
                end
            end
            RevenueEW = RevenueEW + TimeTaken(1,k)*ChargeEW;
            
        else 
            ReferedPatients = ReferedPatients + 1;
            %disp(k);
        end
        k=k+1;

    %----------- MANAGE EMERGENCY WARD ----------------
    else
        dept = WhichDept(k);
        for p=1:TotalBeds(dept)
            if(TimeDept(dept,p)<=i && TimeDept(dept,p)~=0)
                NumBeds(dept) = NumBeds(dept) + 1;
                TimeDept(dept,p)=0;
            end
        end

        if(NumBeds(dept)>0  && TimeOfArrival(1,k)<=i)
            WaitingTime(1,k) = i - TimeOfArrival(1,k);
            TotalPatientDept(1,dept) = TotalPatientDept(1,dept) + 1;
            if(WaitingTime(1,k)~=0)
                PatientWaitDeptwise(1,dept) = PatientWaitDeptwise(1,dept) + 1;
            end
            %X = ['Patient :', num2str(k)," Waiting time: ", num2str(WaitingTime(1,k))];
            %disp(X);
            WaitDept(1,dept) = WaitDept(1,dept) + WaitingTime(k);
            NumBeds(dept) = NumBeds(dept) - 1;
            ServiceTimeDept(1,dept) = ServiceTimeDept(1,dept) + TimeTaken(1,k);
            for i=1:10
                for j = 1:TotalBeds(i)
                    if(TimeDept(i,j)==0)
                        TimeDept(i,j)= i + TimeTaken(1,k);
                    end
                end
            end
            TotalRevenue(dept) = TotalRevenue(dept) + TimeTaken(k)*Charge(dept);
            k=k+1;
        end



    end
    
end

% ---------- Output -------------------- %

disp("Avg Waiting Time as per Dept:");
disp(" ");
for rev=1:10
    X = [Departments(rev)," : ", num2str(WaitDept(rev)/TotalPatientDept(1,rev))];
    disp(X);
end

disp("Revenue as per Dept:");
disp(" ");
for rev=1:10
    X = [Departments(rev)," : ", num2str(TotalRevenue(rev))];
    disp(X);
end

disp("Revenue from the Emergency Department:")
disp(" ");
disp(RevenueEW);

X = ["Refered Patients"," : ", num2str(ReferedPatients)];
disp(X);

figure();
histogram('BinEdges',0:10,'BinCounts',WaitDept, 'FaceColor', 'Red')
title('Waiting time of each Department')
xlabel('Departments')
ylabel('Time')

figure();
histogram('BinEdges',0:10,'BinCounts',TotalRevenue, 'FaceColor', 'Yellow')
title('Revenue of each department')
xlabel('Departments')
ylabel('Revenue')
%hold on

TotalWhoWait = sum(PatientWaitDeptwise);
X = ["Probability of Waiting :", num2str(TotalWhoWait/N)];
disp(X);

AvgServiceTimeDept = zeros(1,10);
for i=1:10
    AvgServiceTimeDept(1,i) = ServiceTimeDept(1,i)/TotalPatientDept(1,i);
end

figure();
histogram('BinEdges',0:10,'BinCounts',AvgServiceTimeDept, 'FaceColor', 'Green')
title('Average Service Time of each Department')
xlabel('Departments')
ylabel('ServiceTime')


AvgThoseWhoWaitDept = zeros(1,10);
for i=1:10
    if(PatientWaitDeptwise(1,i)~=0)
        AvgThoseWhoWaitDept(1,i) = WaitDept(1,i)/PatientWaitDeptwise(1,i);
    else
        AvgThoseWhoWaitDept(1,i)=0;
    end
    %disp(AvgThoseWhoWaitDept(1,i));
end

figure();
histogram('BinEdges',0:10,'BinCounts', AvgThoseWhoWaitDept, 'FaceColor', '#EDB120')
title('Average of Those Who wait')
xlabel('Departments')
ylabel('Time')
