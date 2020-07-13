clear all 

% Parameters
n = 4; # number of nodes in the network
r1 = .15; % line resistance 
x1 = .15; % line reactance 

% Define variables
pi = sdpvar(n,1,'full'); 
qi = sdpvar(n,1,'full');
vi = sdpvar(n,1,'full'); 
P = sdpvar(n,1,'full');
Q = sdpvar(n,1,'full'); 

%% flexibility polytope 
% box constraints 
  A0 =[ 1   0
        1   0
        0   1
        0  -1
        ];
  b0 = [4 2 10 2 ]';

% Convex Polytodes 
% A0 = Pnode.A; 
% b0 = Pnode.b; 

% x = sdpvar(2,1);
% plot(A0*x <= b0);alpha(.01)

% Define constraints 
Constraints = [];
Vmin 
for i = 2 : n
  Constraints = [Constraints, A0*[pi(i) qi(i)]' <= b0 ];
end

for i = 1 : n
  Constraints = [Constraints, vi(i)>= Vmin , vi(i)<= Vmax ];
end

  Constraints = [Constraints, vi(2) == vi(1) - 2*r1*P(1) - 2*x1*Q(1) ];
  Constraints = [Constraints, vi(3) == vi(2) - 2*r1*P(2) - 2*x1*Q(2) ];
  Constraints = [Constraints, vi(4) == vi(3) - 2*r1*P(3) - 2*x1*Q(3) ];

  Constraints = [Constraints, P(2) == P(1) - pi(2) ];
  Constraints = [Constraints, P(3) == P(2) - pi(3) ];
  Constraints = [Constraints, P(4) == P(3) - pi(4) ];
  Constraints = [Constraints, P(4) == 0 ];

  Constraints = [Constraints, Q(2) == Q(1) - qi(2) ];
  Constraints = [Constraints, Q(3) == Q(2) - qi(3) ];
  Constraints = [Constraints, Q(4) == Q(3) - qi(4) ];
  Constraints = [Constraints, Q(4) == 0 ];
  
   Constraints = [Constraints, P(2) == Pflow];
   Constraints = [Constraints, pi(1) == 0, qi(1)==0 ];
  % Constraints = [Constraints, P(1) == 1, Q(1) == 0.2  ];
  
  
% Define an objective
Objective = 0;
%for i = 1:n
  Objective = Objective + P(1);
%end

% Set options for YALMIP and solver
options = sdpsettings('verbose',1,'solver','linprog','linprog.maxiter',100);

% Solve the problem
sol = optimize(Constraints,Objective,options);

% Analyze error flags
if sol.problem == 0
  % Extract and display value
  solution = [value(pi'); value(qi'); value(P') ; value(Q'); value(vi')]'
  [value(P(1)) value(Q(1))]
else
  display('Something went wrong!');
  sol.info
  yalmiperror(sol.problem)
end
