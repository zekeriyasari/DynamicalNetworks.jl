# Notes 

#### We cannot formulate the inequality assumptions in the pinning control problems as a semidefinite programming problem

Consider the network given as 
$$
\dot{x}_i = f(x_i) + \epsilon \sum_{j = 1}^n \xi_{ij} P x_j \quad i = 1, 2, \ldots, n
$$
where $f: \mathbb{R}^d \mapsto \mathbb{R}^d$ is the function corresponding to the node dynamics and the diagonal matrix $P = diag(p_1, p_2, \ldots, p_d)$ is the inner coupling matrix. 

In the pinning control analysis of this network, we assume that there exist a symmetric matrix $K$ such that 
$$
(x - y)^T (f(x) - f(y)) \leq (x-y)^T K P (x - y) \quad \forall x, y \in \mathbb{R}^d \tag{1}
$$
Here the node dynamics function $f$ and the inner coupling matrix $P$ determines $K$. At first using optimization techniques such as semi-definite programming (SDP) can be used the matrix $K$. The problem can be formulated as a feasibility problem subjected a linear matrix inequality (LMI). An LMI is given as 
$$
L(x) = F_0 + \sum_{i = 1}^m x_i F_i
$$
where $x = [x_1, x_2, \ldots, x_m]$ is the optimization variable and $F_i = F_i^T, i = 1, 2, \ldots, m$ are the constant symmetric matrices. 

The problem here is that the inequality in (1) cannot be formulated as and LMI because of the term $f(x) - f(y)$. This implies that the variables $x$ and $y$ must be optimization variables, which in turn makes the optimization problem not semi-definite programming.
