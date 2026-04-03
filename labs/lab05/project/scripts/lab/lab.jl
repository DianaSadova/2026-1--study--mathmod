using Plots
using DifferentialEquations
using LinearAlgebra

x0 = 9
y0 = 19
a = 0.67
b = 0.067
c = 0.66
d = 0.065

dt = 0.5

println("Параметры задачи:")
println("  X₀ = $x0")
println("  Y₀ = $y0")
println("  Коэффициент естественной смертности хищников = $a")
println("  Коэффициент естественного прироста жертв  = $b")
println("  Коэффициент увеличения числа хищников = $c")
println("  Коэффициент смертности жертв = $d")

println("  Шаг = $dt")

t = (0, 200)


println("  Интервал времени моделирования = $t")

function model1!(du, u, p, t)
    x, y = u
    du[1] = a*x - b*x*y
    du[2] = -c*y + d*x*y
end

mkpath("plots")

u0 = [x0, y0]

prob1 = ODEProblem(model1!, u0, t)

sol1 = solve(prob1, Tsit5(), saveat=dt)

t = sol1.t
x = sol1[1,:]
y = sol1[2,:]

p1 = plot(t, x, label="Жертвы (x)", xlabel="Время", ylabel="Численность", linewidth=2)
plot!(p1, t, y, label="Хищники (y)", linewidth=2, linestyle=:dash)
title!(p1, "Динамика численности популяций во времени")

p2 = plot(x, y, label="Фазовая траектория", xlabel="Численность жертв (x)",
          ylabel="Численность хищников (y)", linewidth=2)
scatter!(p2, [10.15], [10], label="Стационарное состояние", color=:red, markersize=6)
title!(p2, "Фазовый портрет: хищники vs жертвы")

plot(p1, p2, layout=(2,1), size=(800, 600))

println("\n" * "="^50)
println("РЕЗУЛЬТАТЫ МОДЕЛИРОВАНИЯ")
println("="^50)

println("Стационарное состояние:")
println("x0 = ", 0.66/0.065, " (жертвы)")
println("y0 = ", 0.67/0.067, " (хищники)")

savefig(p1, "plots/case1.png")
savefig(p2, "plots/case2.png")

println("  plots/case1.png")
println("  plots/case2.png")

println("\nПрограмма завершена!")
