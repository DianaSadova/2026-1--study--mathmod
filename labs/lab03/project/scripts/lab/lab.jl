using Plots
using DifferentialEquations
using LinearAlgebra

x0 = 21050
y0 = 8900
t0 = 0
tmax = 1
dt = 0.05

println("Параметры задачи:")
println("  X₀ = $x0")
println("  Y₀ = $y0")
println("  Начальный момент времени = $t0")
println("  Предельный момент времени = $tmax")
println("  Шаг изменения времени = $dt")

u0 = [x0, y0]

tspan = (0.0, tmax)


println("  u0 = $u0")
println("  tspan = $tspan")

function model1!(du, u, p, t)

    x = u[1]
    y = u[2]

    du[1] = -0.32*x - 0.74*y + 2 + sin(t)   # изменение армии X
    du[2] = -0.44*x - 0.52*y + 2 + cos(t)   # изменение армии Y
end

mkpath("plots")

prob1 = ODEProblem(model1!, u0, tspan)

sol1 = solve(prob1, saveat=dt)

p1 = plot(sol1,
    label = ["Армия X" "Армия Y"],
    xlabel = "Время",
    ylabel = "Численность армии",
    title = "Модель 1: Регулярные армии",
    lw = 2)

function model2!(du, u, p, t)

    x = u[1]
    y = u[2]

    du[1] = -0.39*x - 0.84*y + sin(2*t)        # регулярная армия
    du[2] = -0.42*x*y - 0.49*y + cos(2*t)      # партизанские отряды
end

prob2 = ODEProblem(model2!, u0, tspan)

sol2 = solve(prob2, saveat=dt/10)

p2 = plot(sol2,
    label = ["Армия X (регулярная)" "Армия Y (партизаны)"],
    xlabel = "Время",
    ylabel = "Численность армии",
    title = "Модель 2: Регулярная армия против партизан",
    lw = 2)

function model3!(du, u, p, t)

    x = u[1]
    y = u[2]

    a = 0.25     # потери армии X не связанные с боем
    b = 0.33     # эффективность армии Y (взаимодействие)
    c = 0.28     # эффективность армии X (взаимодействие)
    h = 0.47     # потери армии Y не связанные с боем

    P = 2.5
    Q = 1.5

    du[1] = -a*x - b*x*y + P
    du[2] = -h*y - c*x*y + Q
end

prob3 = ODEProblem(model3!, u0, tspan)

sol3 = solve(prob3, saveat=dt/20)

p3 = plot(sol3,
    label = ["Партизаны X" "Партизаны Y"],
    xlabel = "Время",
    ylabel = "Численность армии",
    title = "Модель 3: Партизаны против партизан",
    lw = 2)

plot(p1, p2, p3, layout=(1,3), size=(1200, 400))

println("\n" * "="^50)
println("РЕЗУЛЬТАТЫ МОДЕЛИРОВАНИЯ")
println("="^50)

x_end1 = sol1(1.0)[1]
y_end1 = sol1(1.0)[2]
println("\nСлучай 1 (Регулярные армии):")
println("  X(1) = $(round(x_end1, digits=2))")
println("  Y(1) = $(round(y_end1, digits=2))")
if x_end1 > y_end1
    println("  ПОБЕДИТЕЛЬ: Армия X")
elseif x_end1 < y_end1
    println("  ПОБЕДИТЕЛЬ: Армия Y")
else
    println("  НИЧЬЯ")
end

x_end2 = sol2(1.0)[1]
y_end2 = sol2(1.0)[2]
println("\nСлучай 2 (Регулярная армия vs Партизаны):")
println("  X(1) = $(round(x_end2, digits=2))")
println("  Y(1) = $(round(y_end2, digits=2))")
if x_end2 > y_end2
    println("  ПОБЕДИТЕЛЬ: Регулярная армия X")
elseif x_end2 < y_end2
    println("  ПОБЕДИТЕЛЬ: Партизаны Y")
else
    println("  НИЧЬЯ")
end

x_end3 = sol3(1.0)[1]
y_end3 = sol3(1.0)[2]
println("\nСлучай 3 (Партизаны vs Партизаны):")
println("  X(1) = $(round(x_end3, digits=2))")
println("  Y(1) = $(round(y_end3, digits=2))")
if x_end3 > y_end3
    println("  ПОБЕДИТЕЛЬ: Партизаны X")
elseif x_end3 < y_end3
    println("  ПОБЕДИТЕЛЬ: Партизаны Y")
else
    println("  НИЧЬЯ")
end

savefig(p1, "plots/case1.png")
savefig(p2, "plots/case2.png")
savefig(p3, "plots/comparison.png")

println("\n" * "="^60)
println("ГРАФИКИ СОХРАНЕНЫ")
println("="^60)
println("  plots/case1.png")
println("  plots/case2.png")
println("  plots/comparison.png")

println("\nПрограмма завершена!")
