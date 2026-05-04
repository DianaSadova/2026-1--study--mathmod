using Plots
using DifferentialEquations
using LinearAlgebra

M01 = 3.3
M02 = 2.3
N = 33
p_cr = 22
tau1 = 22
p1 = 6.6
tau2 = 11
p2 = 11.1
V = 10
q = 1

dt = 0.01
t_span = (0.0, 30.0)

println("Параметры задачи:")
println("  число потребителей производимого продукта = $N")
println("  оборотные средства предприятия 1 = $M01")
println("  оборотные средства предприятия 2 = $M02")
println("  критическая стоимость продукта = $p_cr")
println("  длительность производственного цикла фирмы 1 = $tau1")
println("  себестоимость продукта у фирмы 1 = $p1")
println("  длительность производственного цикла фирмы 2 = $tau2")
println("  себестоимость продукта у фирмы 2 = $p2")
println("  число потребителей производимого продукта = $V")
println("  максимальная потребность одного человека в продукте в единицу времени = $q")
println("  шаг dt = $dt")
println("  интервал времени = $t_span")

mkpath("plots")

a1 = p_cr/(tau1*tau1*p1*p1*V*q);
a2 = p_cr/(tau2*tau2*p2*p2*V*q);
b = p_cr/(tau1*tau1*tau2*tau2*p1*p1*p2*p2*V*q);
c1 = (p_cr-p1)/(tau1*p1);
c2 = (p_cr-p2)/(tau2*p2);

println("  c1 = $c1")
println("  c2 = $c2")

function case1!(du, u, p, θ)
    M1, M2 = u

    du[1] = (c1/c1)*M1 - (a1/c1)*M1^2 - (b/c1)*M1*M2
    du[2] = (c2/c1)*M2 - (a2/c1)*M2^2 - (b/c1)*M1*M2
end

u0 = [M01, M02]
prob1 = ODEProblem(case1!, u0, t_span)
sol1 = solve(prob1, Tsit5(), saveat=dt, reltol=1e-8, abstol=1e-8)

θ1 = sol1.t
M1_case1 = sol1[1, :]
M2_case1 = sol1[2, :]

p1 = plot(θ1, M1_case1, label="Фирма 1 (M₁)", xlabel="Безразмерное время θ",
          ylabel="Оборотные средства M (млн)", linewidth=2, color=:blue)
plot!(p1, θ1, M2_case1, label="Фирма 2 (M₂)", linewidth=2, color=:green)
title!(p1, "Случай 1: Только рыночные методы конкуренции")
hline!(p1, [0], linestyle=:dash, color=:black, label="")
savefig(p1, "plots/case1.png")

function case2!(du, u, p, θ)
    M1, M2 = u
    du[1] = (c1/c1)*M1 - (a1/c1)*M1^2 - (b/c1)*M1*M2
    du[2] = 0.00093*M2 - (a2/c1)*M2^2 - (b/c1)*M1*M2
end

prob2 = ODEProblem(case2!, u0, t_span)
sol2 = solve(prob2, Tsit5(), saveat=dt, reltol=1e-8, abstol=1e-8)

θ2 = sol2.t
M1_case2 = sol2[1, :]
M2_case2 = sol2[2, :]

p2 = plot(θ2, M1_case2, label="Фирма 1 (M₁)", xlabel="Безразмерное время θ",
          ylabel="Оборотные средства M (млн)", linewidth=2, color=:blue)
plot!(p2, θ2, M2_case2, label="Фирма 2 (M₂)", linewidth=2, color=:green)
title!(p2, "Случай 2: С социально-психологическим фактором")
hline!(p2, [0], linestyle=:dash, color=:black, label="")
savefig(p2, "plots/case2.png")

idx_bankrupt = findfirst(M1_case2 .<= 0)
if !isnothing(idx_bankrupt)
    θ_bankrupt = θ2[idx_bankrupt]
    println("Случай 2 (с социально-психологическим фактором):")
    println("  Фирма 1 терпит банкротство при θ ≈ $(round(θ_bankrupt, digits=2))")
else
    println("Случай 2: Фирма 1 не обанкротилась за время моделирования")
end

println("="^60)

A = [a1 b; b a2]
rhs = [c1; c2]

det_A = det(A)
println("Определитель матрицы A = $(det_A)")

if abs(det_A) > 1e-12
    M_star = A \ rhs
    println("\nНенулевое стационарное состояние (устойчивое):")
    println("  M₁* = $(round(M_star[1], digits=2)) млн")
    println("  M₂* = $(round(M_star[2], digits=2)) млн")
else
    println("\nМатрица вырождена, система имеет множество решений или несовместна")
end

println("\nГраничные стационарные состояния:")
println("  1. (M₁, M₂) = (0, 0) - тривиальное, неустойчивое")
if c2 > 0
    M2_zero_M1 = c2 / a2
    println("  2. (M₁, M₂) = (0, $(round(M2_zero_M1, digits=2))) - фирма 1 отсутствует")
end
if c1 > 0
    M1_zero_M2 = c1 / a1
    println("  3. (M₁, M₂) = ($(round(M1_zero_M2, digits=2)), 0) - фирма 2 отсутствует")
end
println()

p_compare = plot(θ1, M1_case1, label="Случай 1: Фирма 1",
                 xlabel="Безразмерное время θ",
                 ylabel="Оборотные средства M (млн)",
                 linewidth=2, color=:blue, linestyle=:solid)
plot!(p_compare, θ1, M2_case1, label="Случай 1: Фирма 2",
      linewidth=2, color=:green, linestyle=:solid)
plot!(p_compare, θ2, M1_case2, label="Случай 2: Фирма 1",
      linewidth=2, color=:red, linestyle=:dash)
plot!(p_compare, θ2, M2_case2, label="Случай 2: Фирма 2",
      linewidth=2, color=:orange, linestyle=:dash)
title!(p_compare, "Сравнение случаев 1 и 2")
hline!(p_compare, [0], linestyle=:dash, color=:black, label="")
savefig(p_compare, "plots/comparison_cases.png")

p_phase = plot(M1_case1, M2_case1, label="Случай 1 (траектория)",
               xlabel="M₁ (млн)", ylabel="M₂ (млн)",
               linewidth=2, color=:blue)
plot!(p_phase, M1_case2, M2_case2, label="Случай 2 (траектория)",
      linewidth=2, color=:red, linestyle=:dash)

if abs(det_A) > 1e-12
    scatter!(p_phase, [M_star[1]], [M_star[2]],
             label="Стационарная точка (случай 1)",
             markershape=:circle, color=:black, markersize=8)
end

scatter!(p_phase, [M01], [M02], label="Начальное состояние (M₁₀, M₂₀)",
         markershape=:star, color=:green, markersize=10)

title!(p_phase, "Фазовый портрет системы")
savefig(p_phase, "plots/phase_portrait.png")

println("="^60)

if !isnothing(idx_bankrupt)
    println("   - Фирма 1 терпит банкротство при θ ≈ $(round(θ_bankrupt, digits=2))")
else
    println("   - Фирма 1 вытесняется с рынка")
end
println("   - Фирма 2 полностью монополизирует рынок")

println("\n Стационарные состояния (случай 1):")
if abs(det_A) > 1e-12
    println("   - Устойчивое состояние: M₁* = $(round(M_star[1], digits=2)) млн, M₂* = $(round(M_star[2], digits=2)) млн")
end
println("   - Неустойчивое тривиальное состояние: (0, 0)")

plot(p1, p2, p_compare, p_phase,
     layout=(2, 2), size=(1200, 1000),
     plot_title="Модель конкуренции двух фирм (Вариант 39)")
savefig("plots/all_plots.png")

println("\nВсе графики сохранены в папку 'plots/'")
println("Файлы:")
println("  - case1.png (Случай 1)")
println("  - case2.png (Случай 2)")
println("  - comparison_cases.png (Сравнение случаев)")
println("  - phase_portrait.png (Фазовый портрет)")
println("  - all_plots.png (Все графики вместе)")
