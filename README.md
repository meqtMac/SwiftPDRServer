# SwiftPDRServer
A light swift programming language server using Vapor framework for school course.

## PDR
在行人定位领域，行人航位推算(PDR)是一种主流方法。传统的PDR算法依赖惯性测量单元(Inertia Measurement Unit，IMU)收集行人的加速度、角速度等信息，进而推算行人的运动轨迹.

$$
\begin{aligned}
     x_t &= x_{t-1} + l_{t-1} \times \cos \theta_{t-1}  \\
     y_t &= y_{t-1} + l_{t-1} \times \sin \theta_{t-1} 
    \end{aligned}
$$

假设前一步点的位置为 $(x_{t-1},y_{t-1})$， $t-1$到 $t$时刻之间的步长为 $l_{t-1}$，行进
方向角度为 $\theta_{t-1}$。根据上式即可解出 $t$时刻行人的估计位置 $(x_t, y_t)$。

PDR算法主要包括步频检测、步长估计、航向估计三个任务。

## 系统架构
该软件的系统架构为B/S架构，前端负责网页设计，后端负责编写API接口， 调用设计的算法并利用数据库中的数据并来实现对室内行人定位轨迹的校正，并在网页上实现轨迹的可视化。后端通过API接口平台，测试对应的API接口;前端利用API接口，测试网页显示内容是否正确，交互是否成功。算法模型通过CDF曲线以及平均定位误差来判断优劣;联调测试:前后端联调，观察软件是否达到理想的效果，是否满足了所有的用户需求。

### API
| Method | Path | Description |
| --- | --- | --- |
| GET | /batchs | get all available batchs |
| GET | /runnings | get running dataset with a query of batch |
| POST | /runnings | upload runnings dataset |
| GET | /runnings/pdr | call PDREngine to predict with a batch marking one running dataset |
| GET | /positions | get position dataset with a query of batch |
| POST | /positions | create positions dataset |
| GET | /truepoint | get position dataset with a query of batch  |
| POST | /truepoint | upload ground truth |

## 算法设计
在PDREngine中实现算法相关函数
### calerror
用于计算误差，由于预测点与ground truth的含义不同，故采用临近两点的线性插值。
### predict

对一组数据航位预测，主要包含一下三个部分：
#### 航位推算
考虑到人的加速度远小于重力加速度，记三轴加速度的方向向量在设备参考系中为 $a$，三轴角加速度为 $g$
有

$$\begin{aligned}
    \mathbf{d}\theta & = \vec{a}\cdot \vec{g} \times \mathbf{d}t \\
    \vec{g} & = (g_x, g_y, g_z) \\
    \theta_t  & = \int d \theta + \theta_0
    \end{aligned}
$$

为了消除人体加速的影响，引入一个常数因子 $m$，由预训练得出，对应公式修改为

$$
\mathbf{d}\theta  = m \ \vec{a}\cdot \vec{g} \times \mathbf{d}t
$$

#### 峰值检测
在算法中，仅检测Z轴加速度的最大值，绘制单个batch的Z轴加速度波形发现一步之间的采样点数有限，同时在出现在波峰处的噪声，影响了峰值点的准确判断，故扩大峰值的检测的范围，将临近局部最大值合并。

#### 步长推算
根据公式

$$ l_n = K \times (a_n^{max} - a_n^{min})^{ \frac{1}{4}}
$$

其中， $l_n$是第 $n$步的步长； $a_n^{max}$和 $a_n^{min}$分别表示第$n$步的Z轴加速度最大值和最小值； $K$为常数，通过对给出的数据训练得出。

同时观察数据发现，加速的采样点有限，在一个步长范围内不能准确的求出最大值和最小值，故通过训练来修正步长误差。

#### train
在类中存储一个参数列表，调用train函数训练参数，并不断迭代PDREngine中的参数。训练的目标为最小化平均误差 $E$，记参数列表为 $\vec{v}$本模型中只有两个参数记为 $\vec{v}=(v_1,v_2)$，利用梯度下降法.

$$\begin{aligned}
    \Delta E & \approx \frac{\partial E}{\partial v_1} \Delta v_1 + \frac{\partial E}{\partial v_2} \Delta v_2 \\
    \nabla E & \equiv \left( \frac{\partial E}{\partial v_1}, \frac {\partial E}{\partial v_1}\right)^T  \\
    \Delta E & \approx \nabla E \cdot \Delta v \\
    \Delta v & = - \eta \nabla E \\
    v \to v' & = v - \eta \nabla E 
    \end{aligned}
$$

手动设定训练参数，在服务器上离线训练。

## 算法误差
|Batch|$50\%$|$75\%$|$90\%$|Average|
|---|---|---|---|---|
| 27 | 2.208 | 2.982 | 3.237 | 1.77 |
| 28 | 2.985 | 4.087 | 4.41 | 2.455 |
| 29 | 0.879 | 1.332 | 1.476 | 0.768 |
| 30 | 1.579 | 2.626 | 2.85 | 1.631 |
| 31 | 1.609 | 1.973 | 2.19 | 1.439 |
| 32 | 0.68 | 1.337 | 1.772 | 0.889 |
