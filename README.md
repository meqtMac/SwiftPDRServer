# SwiftPDRServer
A light swift programming language server using Vapor framework for school course.

## PDR
在行人定位领域，行人航位推算(PDR)是一种主流方法\cite{duckworth1999wildlife}\cite{齐保振2013基于运动传感的个人导航系统及算法研究}。传统的PDR算法依赖惯性测量单元(Inertia Measurement Unit，IMU)收集行人的加速度、角速度等信息，进而推算行人的运动轨迹，见\reffig{pdrfig}。

\begin{figure}[htbp]
	\centering
	\includegraphics[width=0.5\textwidth]{fig/pdr.png}
	\caption{PDR示意图}
	\label{pdrfig}
\end{figure}

\begin{equation}
    \begin{aligned}
     x_t &= x_{t-1} + l_{t-1} \times \cos \theta_{t-1}  \\
     y_t &= y_{t-1} + l_{t-1} \times \sin \theta_{t-1} 
    \end{aligned}
\end{equation}

假设前一步点的位置为$(x_{t-1},y_{t-1})$，$t-1$到$t$时刻之间的步长为$l_{t-1}$，行进
方向角度为$\theta_{t-1}$。根据上式即可解出$t$时刻行人的估计位置$(x_t, y_t)$。

PDR算法主要包括步频检测、步长估计、航向估计三个任务。
