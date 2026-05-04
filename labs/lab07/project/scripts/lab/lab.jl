using Plots
using DifferentialEquations
using LinearAlgebra

N = 1150
n0 = 12.0  # начальное количество знающих

dt = 0.1
t_span = (0.0, 300.0)

println("Параметры задачи:")
println("  объем аудитории N = $N")
println("  начальное число знающих = $n0")
println("  шаг dt = $dt")
println("  интервал времени = $t_span")

mkpath("plots")

function model1!(du, u, p, t)
    n = u[1]
    α₁ = 0.67
    α₂ = 0.000067
    du[1] = (α₁ + α₂ * n) * (N - n)
end

u0 = [n0]
prob1 = ODEProblem(model1!, u0, t_span)
sol1 = solve(prob1, Tsit5(), saveat=dt)

t1 = sol1.t
n1 = sol1[1, :]

p1 = plot(t1, n1, label="Число знающих n(t)", xlabel="Время t",
          ylabel="Количество человек", linewidth=2, color=:blue)
plot!(p1, t1, fill(N, length(t1)), label="Потенциальная аудитория N=$N",
      linestyle=:dash, color=:red)
title!(p1, "Модель 1: α₁=0.67, α₂=0.000067")
savefig(p1, "plots/model1.png")

println("\n--- Модель 1 ---")
println("  α₁ = 0.67 (высокая платная реклама)")
println("  α₂ = 0.000067 (очень слабое сарафанное радио)")
println("  Итог: быстрый рост за счет платной рекламы")

function model2!(du, u, p, t)
    n = u[1]
    α₁ = 0.000076
    α₂ = 0.76
    du[1] = (α₁ + α₂ * n) * (N - n)
end

prob2 = ODEProblem(model2!, u0, t_span)
sol2 = solve(prob2, Tsit5(), saveat=dt)

t2 = sol2.t
n2 = sol2[1, :]

v2 = @. (0.000076 + 0.76 * n2) * (N - n2)

v_max, idx_max = findmax(v2)
t_max = t2[idx_max]
n_at_max = n2[idx_max]

p2 = plot(t2, n2, label="Число знающих n(t)", xlabel="Время t",
          ylabel="Количество человек", linewidth=2, color=:green)
plot!(p2, t2, fill(N, length(t2)), label="Потенциальная аудитория N=$N",
      linestyle=:dash, color=:red)
scatter!(p2, [t_max], [n_at_max], markershape=:circle, color=:red,
         markersize=8, label="Максимальная скорость: t=$t_max")
title!(p2, "Модель 2: α₁=0.000076, α₂=0.76")
savefig(p2, "plots/model2.png")

p2_speed = plot(t2, v2, label="Скорость распространения dn/dt",
                xlabel="Время t", ylabel="Скорость", linewidth=2, color=:purple)
scatter!(p2_speed, [t_max], [v_max], markershape=:circle, color=:red,
         markersize=8, label="Максимум: t=$t_max, v=$v_max")
title!(p2_speed, "Скорость распространения рекламы (модель 2)")
savefig(p2_speed, "plots/model2_speed.png")

println("\n--- Модель 2 ---")
println("  α₁ = 0.000076 (очень слабая платная реклама)")
println("  α₂ = 0.76 (сильное сарафанное радио)")
println("  Итог: медленный старт, затем взрывной рост")
println("  Максимальная скорость распространения: $v_max чел/ед.времени")
println("  Время достижения максимальной скорости: t = $t_max")
println("  Количество знающих в этот момент: n = $n_at_max человек")
println("  (теоретически максимум скорости при n ≈ N/2 = $(N/2))")

function model3!(du, u, p, t)
    n = u[1]
    α₁ = 0.76 * sin(t)
    α₂ = 0.67 * cos(t)
    du[1] = (α₁ + α₂ * n) * (N - n)
end

prob3 = ODEProblem(model3!, u0, t_span)
sol3 = solve(prob3, Tsit5(), saveat=dt)

t3 = sol3.t
n3 = sol3[1, :]

p3 = plot(t3, n3, label="Число знающих n(t)", xlabel="Время t",
          ylabel="Количество человек", linewidth=2, color=:orange)
plot!(p3, t3, fill(N, length(t3)), label="Потенциальная аудитория N=$N",
      linestyle=:dash, color=:red)
title!(p3, "Модель 3: α₁=0.76·sin(t), α₂=0.67·cos(t)")
savefig(p3, "plots/model3.png")

println("\n--- Модель 3 ---")
println("  α₁(t) = 0.76·sin(t) (переменная платная реклама)")
println("  α₂(t) = 0.67·cos(t) (переменное сарафанное радио)")
println("  Итог: периодические колебания интенсивности рекламы")

p_compare = plot(t1, n1, label="Модель 1 (высокая платная)",
                 xlabel="Время t", ylabel="Количество человек",
                 linewidth=2, color=:blue)
plot!(p_compare, t2, n2, label="Модель 2 (высокое сарафанное радио)",
      linewidth=2, color=:green)
plot!(p_compare, t3, n3, label="Модель 3 (переменные коэф.)",
      linewidth=2, color=:orange, linestyle=:dot)
plot!(p_compare, t1, fill(N, length(t1)), label="N=$N",
      linestyle=:dash, color=:red)
title!(p_compare, "Сравнение всех трех моделей распространения рекламы")
savefig(p_compare, "plots/comparison.png")

println("\n" * "="^60)
println("ДОПОЛНИТЕЛЬНЫЙ АНАЛИЗ ДЛЯ ЛАБОРАТОРНОЙ РАБОТЫ")
println("="^60)

function only_paid!(du, u, p, t)
    n = u[1]
    α₁ = 0.67
    α₂ = 0.0
    du[1] = (α₁ + α₂ * n) * (N - n)
end
prob_paid = ODEProblem(only_paid!, u0, t_span)
sol_paid = solve(prob_paid, Tsit5(), saveat=dt)
n_paid = sol_paid[1, :]

function only_wom!(du, u, p, t)  # wom = word of mouth
    n = u[1]
    α₁ = 0.0
    α₂ = 0.76
    du[1] = (α₁ + α₂ * n) * (N - n)
end
prob_wom = ODEProblem(only_wom!, u0, t_span)
sol_wom = solve(prob_wom, Tsit5(), saveat=dt)
n_wom = sol_wom[1, :]

p_methods = plot(t1, n_paid, label="Только платная реклама (α₁=0.67, α₂=0)",
                 xlabel="Время t", ylabel="Количество человек",
                 linewidth=2, color=:magenta)
plot!(p_methods, t1, n_wom, label="Только сарафанное радио (α₁=0, α₂=0.76)",
      linewidth=2, color=:cyan)
plot!(p_methods, t2, n2, label="Комбинированный метод (α₁=0.000076, α₂=0.76)",
      linewidth=2, color=:green, linestyle=:dash)
plot!(p_methods, t1, fill(N, length(t1)), label="N=$N",
      linestyle=:dash, color=:red)
title!(p_methods, "Сравнение эффективности методов распространения рекламы")
savefig(p_methods, "plots/paid_vs_wordofmouth.png")

println("\n--- Сравнение эффективности ---")
println("1. Только платная реклама:")
println("   - Быстрый рост с самого начала")

idx_95 = findfirst(n_paid .> 0.95 * N)
if !isnothing(idx_95)
    println("   - Достигает насыщения за ~$(t1[idx_95]) ед.времени")
else
    println("   - Не достигает насыщения за время моделирования")
end
println("2. Только сарафанное радио:")
println("   - Медленный начальный рост")
println("   - Взрывной рост после накопления критической массы")
println("3. Комбинированный метод:")
println("   - Сочетает преимущества обоих подходов")

println("\n" * "="^60)
println("ОТВЕТ НА ГЛАВНЫЙ ВОПРОС ЗАДАНИЯ")
println("="^60)
println("Для случая 2 (α₁ = 0.000076, α₂ = 0.76):")
println("  Максимальная скорость распространения рекламы достигается")
println("  в момент времени t = $t_max")
println("  при количестве знающих n = $n_at_max человек")
println("  Скорость в этот момент составляет v = $v_max чел/ед.времени")

plot(p1, p2, p3, p_compare, p2_speed, p_methods,
     layout=(3, 2), size=(1200, 1000),
     plot_title="Анализ моделей распространения рекламы")
savefig("plots/all_plots.png")

println("\nВсе графики сохранены в папку 'plots/'")
println("Файлы:")
println("  - model1.png (Модель 1)")
println("  - model2.png (Модель 2)")
println("  - model2_speed.png (Скорость для модели 2)")
println("  - model3.png (Модель 3)")
println("  - comparison.png (Сравнение всех моделей)")
println("  - paid_vs_wordofmouth.png (Сравнение методов)")
println("  - all_plots.png (Все графики вместе)")
