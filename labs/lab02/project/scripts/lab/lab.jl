using Plots
using LinearAlgebra

n = 5.5              # во сколько раз катер быстрее лодки
K = 21.0             # начальное расстояние между катером и лодкой (км)

r01 = K / (n + 1)    # случай 1: лодка удаляется от катера
r02 = K / (n - 1)    # случай 2: лодка движется к катеру

theta0_1 = 0.0       # начальный угол для случая 1 (катер на полярной оси)
theta0_2 = -π        # начальный угол для случая 2 (катер на противоположной стороне)

boat_angle_1 = π/4   # 45° - лодка уходит вправо-вверх
boat_angle_2 = 3π/4  # 135° - лодка уходит влево-вверх

println("Параметры задачи:")
println("  n = $n")
println("  K = $K км")
println("  r01 = $(round(r01, digits=3)) км")
println("  r02 = $(round(r02, digits=3)) км")

function r_kater(theta, r0, theta0, n)
    return r0 .* exp.((theta .- theta0) / sqrt(n^2 - 1))
end

theta1 = range(0, 4π, length=2000)      # случай 1: от 0 до 4π
theta2 = range(-π, 3π, length=2000)     # случай 2: от -π до 3π

r1 = r_kater(theta1, r01, theta0_1, n)
r2 = r_kater(theta2, r02, theta0_2, n)

x1 = r1 .* cos.(theta1)
y1 = r1 .* sin.(theta1)

x2 = r2 .* cos.(theta2)
y2 = r2 .* sin.(theta2)

max_r_boat = 25.0    # максимальное расстояние для отображения
t_boat = range(0, max_r_boat, length=200)

x_boat1 = t_boat .* cos(boat_angle_1)
y_boat1 = t_boat .* sin(boat_angle_1)

x_boat2 = t_boat .* cos(boat_angle_2)
y_boat2 = t_boat .* sin(boat_angle_2)

function find_intersection(x_kater, y_kater, x_boat, y_boat, boat_angle, threshold=0.5)
    min_dist = Inf
    intersection = nothing

    for i in 1:length(x_kater)
        t = x_kater[i]*cos(boat_angle) + y_kater[i]*sin(boat_angle)
        if t > 0  # точка должна быть в направлении луча
            proj_x = t * cos(boat_angle)
            proj_y = t * sin(boat_angle)
            dist = sqrt((x_kater[i] - proj_x)^2 + (y_kater[i] - proj_y)^2)

            if dist < min_dist
                min_dist = dist
                if dist < threshold
                    intersection = (x_kater[i], y_kater[i], t, dist)
                end
            end
        end
    end
    end

    return intersection, min_dist
end

intersection1, dist1 = find_intersection(x1, y1, x_boat1, y_boat1, boat_angle_1)
intersection2, dist2 = find_intersection(x2, y2, x_boat2, y_boat2, boat_angle_2)

println("\n" * "="^60)
println("РЕЗУЛЬТАТЫ")
println("="^60)

println("\nСЛУЧАЙ 1 (катер стартует с θ=0, лодка под 45°):")
if intersection1 !== nothing
    x, y, r, dist = intersection1
    println("  ✅ Точка встречи найдена!")
    println("     Координаты: (x = $(round(x, digits=2)), y = $(round(y, digits=2))) км")
    println("     Расстояние от полюса: $(round(r, digits=2)) км")
    println("     Погрешность: $(round(dist, digits=3)) км")
else
    println("  ❌ Точка встречи не найдена")
    println("     Минимальное расстояние: $(round(dist1, digits=3)) км")
end
println("\nСЛУЧАЙ 2 (катер стартует с θ=-π, лодка под 135°):")
if intersection2 !== nothing
    x, y, r, dist = intersection2
    println("  ✅ Точка встречи найдена!")
    println("     Координаты: (x = $(round(x, digits=2)), y = $(round(y, digits=2))) км")
    println("     Расстояние от полюса: $(round(r, digits=2)) км")
    println("     Погрешность: $(round(dist, digits=3)) км")
else
    println("  ❌ Точка встречи не найдена")
    println("     Минимальное расстояние: $(round(dist2, digits=3)) км")
end

mkpath("plots")

p1 = plot(title="Случай 1: Катер стартует с θ=0, лодка под 45°",
          xlabel="x (км)", ylabel="y (км)",
          aspect_ratio=:equal, legend=:topright,
          size=(600, 500))

plot!(p1, x_boat1, y_boat1,
    label="Лодка (45°)",
    linewidth=3,
    color=:red,
    linestyle=:dash)

plot!(p1, x1, y1,
    label="Катер (спираль)",
    linewidth=2,
    color=:blue)

scatter!(p1, [r01*cos(theta0_1)], [r01*sin(theta0_1)],
    label="Старт катера",
    markershape=:star5,
    color=:blue,
    markersize=8)

scatter!(p1, [0], [0],
    label="Полюс (обнаружение)",
    markershape=:circle,
    color=:black,
    markersize=6)

if intersection1 !== nothing
    scatter!(p1, [intersection1[1]], [intersection1[2]],
        label="Точка встречи",
        markershape=:square,
        color=:green,
        markersize=8)
end

p2 = plot(title="Случай 2: Катер стартует с θ=-π, лодка под 135°",
          xlabel="x (км)", ylabel="y (км)",
          aspect_ratio=:equal, legend=:topright,
          size=(600, 500))

plot!(p2, x_boat2, y_boat2,
    label="Лодка (135°)",
    linewidth=3,
    color=:red,
    linestyle=:dash)

plot!(p2, x2, y2,
    label="Катер (спираль)",
    linewidth=2,
    color=:green)

scatter!(p2, [r02*cos(theta0_2)], [r02*sin(theta0_2)],
    label="Старт катера",
    markershape=:star5,
    color=:green,
    markersize=8)

scatter!(p2, [0], [0],
    label="Полюс (обнаружение)",
    markershape=:circle,
    color=:black,
    markersize=6)

if intersection2 !== nothing
    scatter!(p2, [intersection2[1]], [intersection2[2]],
        label="Точка встречи",
        markershape=:square,
        color=:green,
        markersize=8)
end

p3 = plot(p1, p2, layout=(1,2), size=(1200, 500))

savefig(p1, "plots/case1.png")
savefig(p2, "plots/case2.png")
savefig(p3, "plots/comparison.png")

println("\n" * "="^60)
println("ГРАФИКИ СОХРАНЕНЫ")
println("="^60)
println("  plots/case1.png")
println("  plots/case2.png")
println("  plots/comparison.png")

println("\n" * "="^60)
println("АНАЛИТИЧЕСКОЕ РЕШЕНИЕ")
println("="^60)

sqrt_term = sqrt(n^2 - 1)
println("\nУравнение траектории катера: r(θ) = r₀·exp((θ-θ₀)/√(n²-1))")
println("где √(n²-1) = √($(n^2-1)) = $(round(sqrt_term, digits=4))")
println("\nСлучай 1: r(θ) = $(round(r01, digits=3))·exp(θ/$(round(sqrt_term, digits=3)))")
println("Случай 2: r(θ) = $(round(r02, digits=3))·exp((θ+π)/$(round(sqrt_term, digits=3)))")

display(p3)

println("\nПрограмма завершена!")
