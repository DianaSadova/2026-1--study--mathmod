using Plots
using LinearAlgebra

# ======================
# ПАРАМЕТРЫ ЗАДАЧИ
# ======================
n = 5.5            # во сколько раз катер быстрее лодки
r0 = 21.0          # начальное расстояние (км)
theta0 = 0.0       # случай 1
theta0_2 = -pi     # случай 2

# диапазон угла
theta = range(0, 4pi, length=2000)

# ======================
# ТРАЕКТОРИЯ КАТЕРА
# ======================
function r_kater(theta, r0, n)
    return r0 .* exp.(theta ./ sqrt(n^2 - 1))
end

r1 = r_kater(theta, r0, n)
r2 = r_kater(theta, r0, n)

# ======================
# ПЕРЕХОД В ДЕКАРТОВЫ КООРДИНАТЫ
# ======================
x1 = r1 .* cos.(theta .+ theta0)
y1 = r1 .* sin.(theta .+ theta0)

x2 = r2 .* cos.(theta .+ theta0_2)
y2 = r2 .* sin.(theta .+ theta0_2)

# ======================
# ТРАЕКТОРИЯ ЛОДКИ
# ======================
t = range(0, 50, length=1000)
v = 1.0  # скорость лодки
x_boat = v .* t
y_boat = zeros(length(t))

# ======================
# ПОСТРОЕНИЕ ГРАФИКА
# ======================
plot(x_boat, y_boat,
    label="Лодка браконьеров",
    linewidth=3,
    color=:red)

plot!(x1, y1,
    label="Катер (случай 1)",
    linewidth=2,
    color=:blue)

plot!(x2, y2,
    label="Катер (случай 2)",
    linewidth=2,
    color=:green)

scatter!([0], [0], label="Точка обнаружения", color=:black)

xlabel!("x (км)")
ylabel!("y (км)")
title!("Преследование лодки катером (n = $n)")
aspect_ratio=:equal

