using Plots
using DifferentialEquations
using LinearAlgebra

# ======================
# НАСТРОЙКА ГРАФИКОВ
# ======================

# Принудительно устанавливаем PNG формат для отображения
ENV["GKSwstype"] = "100"  # Отключает интерактивное окно GR
default(show=true, fmt=:png)  # Устанавливаем PNG как формат по умолчанию

# ======================
# ПАРАМЕТРЫ ЗАДАЧИ
# ======================

N = 12800
I0 = 180
R0 = 58
S0 = N - I0 - R0

dt = 0.01

println("Параметры задачи:")
println("  Проживающих на остров = $N")
println("  Число заболевших людей = $I0")
println("  Число здоровых людей с иммунитетом = $R0")
println("  Число людей восприимчивых к болезни = $S0")
println("  Шаг = $dt")

# интервал времени моделирования
t_span = (0, 200)

println("  Интервал времени моделирования = $t_span")


α = 0.01           
β = 0.02           
I_star = 200       

println("  Коэффициент заболеваемости (α) = $α")
println("  Коэффициент выздоровления (β) = $β")
println("  Критическое значение (I*) = $I_star")
# ==========================================================
# 1 МОДЕЛЬ - Задача об эпидемии. Если I <= I*
# ==========================================================

function model1!(du, u, p, t)
    S, I, R = u
    α, β = p
  
    du[1] = 0
    du[2] = -β * I
    du[3] = β * I                  
end

# Начальные условия для случая 1
u0_1 = [S0, I0, R0]
p_1 = (α, β)

# Создаем и решаем задачу
prob1 = ODEProblem(model1!, u0_1, t_span, p_1)
sol1 = solve(prob1, saveat=dt)

# Извлекаем данные
t1 = sol1.t
S1 = sol1[1, :]
I1 = sol1[2, :]
R1 = sol1[3, :]



# ==========================================================
# 2 МОДЕЛЬ — Задача об эпидемии Если I > I*
# ==========================================================

# Для демонстрации второго случая увеличим начальное количество инфицированных
I0_case2 = 250  
S0_case2 = N - I0_case2 - R0

function model2!(du, u, p, t)
    S, I, R = u
    α, β = p
    
    if I > I_star

        du[1] = -α * S * I    
        du[2] = α * S * I - β * I  
    else

        du[1] = 0.0
        du[2] = -β * I
    end
    du[3] = β * I
end

u0_2 = [S0_case2, I0_case2, R0]
p_2 = (α, β)

prob2 = ODEProblem(model2!, u0_2, t_span, p_2)
sol2 = solve(prob2, saveat=dt)

# Извлекаем данные
t2 = sol2.t
S2 = sol2[1, :]
I2 = sol2[2, :]
R2 = sol2[3, :]

# ==========================================================
# ПОСТРОЕНИЕ ГРАФИКОВ
# ==========================================================

# Создаем директорию для сохранения
mkpath("plots")

# Графики для случая 1 (I(0) <= I*)
p1 = plot(title="Случай 1: I(0) = $I0 ≤ I* = $I_star",
          xlabel="Время t", ylabel="Численность",
          legend=:topright, linewidth=2,
          size=(800, 500))

plot!(p1, t1, S1, label="S(t) - Восприимчивые", color=:blue)
plot!(p1, t1, I1, label="I(t) - Инфицированные", color=:red)
plot!(p1, t1, R1, label="R(t) - С иммунитетом", color=:green)
hline!(p1, [I_star], label="I* = $I_star", color=:black, linestyle=:dash, linewidth=1.5)

# Графики для случая 2 (I(0) > I*)
p2 = plot(title="Случай 2: I(0) = $I0_case2 > I* = $I_star",
          xlabel="Время t", ylabel="Численность",
          legend=:topright, linewidth=2,
          size=(800, 500))

plot!(p2, t2, S2, label="S(t) - Восприимчивые", color=:blue)
plot!(p2, t2, I2, label="I(t) - Инфицированные", color=:red)
plot!(p2, t2, R2, label="R(t) - С иммунитетом", color=:green)
hline!(p2, [I_star], label="I* = $I_star", color=:black, linestyle=:dash, linewidth=1.5)

# Фазовый портрет для случая 2 (I vs S)
p2_phase = plot(title="Фазовый портрет: I(t) vs S(t) (Случай 2)",
                xlabel="S(t) - Восприимчивые", ylabel="I(t) - Инфицированные",
                legend=:topright, linewidth=2,
                size=(600, 500))

plot!(p2_phase, S2, I2, label="Фазовая траектория", color=:purple)
scatter!(p2_phase, [S0_case2], [I0_case2], label="Начальная точка", color=:red, markersize=6)

# ==========================================================
# ДОПОЛНИТЕЛЬНЫЙ АНАЛИЗ
# ==========================================================

# Находим максимум эпидемии для случая 2
I_max = maximum(I2)
t_max = t2[argmax(I2)]

println("\n Результаты моделирования")


println("\nСлучай 1 (больные изолированы):")
println("  Инфицированные уменьшаются по экспоненте: I(t) = $I0 * exp(-β*t)")
println("  Конечное число инфицированных: I(конечное) = $(round(I1[end], digits=2))")
println("  Конечное число с иммунитетом: R(конечное) = $(round(R1[end], digits=2))")
println("  Все восприимчивые остались здоровыми: S(конечное) = $(round(S1[end], digits=2))")

println("\nСлучай 2 (эпидемия развивается):")
println("  Пик эпидемии: $(round(I_max, digits=2)) инфицированных в момент t = $(round(t_max, digits=2))")
println("  Конечное число восприимчивых: S(конечное) = $(round(S2[end], digits=2))")
println("  Конечное число с иммунитетом: R(конечное) = $(round(R2[end], digits=2))")
println("  Общее число переболевших: $(round(R2[end] - R0, digits=2))")

# Базовое репродуктивное число R0
R0_basic = α * N / β
println("\nБазовое репродуктивное число R₀ = α*N/β = $(round(R0_basic, digits=3))")
if R0_basic > 1
    println("  R₀ > 1 - Эпидемия возможна")
else
    println("  R₀ < 1 -  Эпидемия невозможна")
end

# ==========================================================
# СОХРАНЕНИЕ ГРАФИКОВ
# ==========================================================

println("\nСохранение графиков...")

savefig(p1, "plots/case1_I0_leq_Istar.png")
println("  Сохранён: plots/case1_I0_leq_Istar.png")

savefig(p2, "plots/case2_I0_gt_Istar.png")
println("  Сохранён: plots/case2_I0_gt_Istar.png")

savefig(p2_phase, "plots/case2_phase_portrait.png")
println("  Сохранён: plots/case2_phase_portrait.png")

# Сравнительный график I(t) для обоих случаев
p_compare = plot(title="Сравнение динамики инфицированных I(t)",
                 xlabel="Время t", ylabel="I(t) - Инфицированные",
                 legend=:topright, linewidth=2,
                 size=(800, 500))

plot!(p_compare, t1, I1, label="Случай 1: I(0)=$I0 ≤ I*", color=:blue)
plot!(p_compare, t2, I2, label="Случай 2: I(0)=$I0_case2 > I*", color=:red)
hline!(p_compare, [I_star], label="I* = $I_star", color=:black, linestyle=:dash, linewidth=1.5)

savefig(p_compare, "plots/comparison_I_t.png")
println("  Сохранён: plots/comparison_I_t.png")

# ==========================================================
# ОТОБРАЖЕНИЕ ГРАФИКОВ
# ==========================================================

println("\nОтображение графиков...")
display(p1)
display(p2)
display(p2_phase)
display(p_compare)

println("\n Программа успешно завершена!")

