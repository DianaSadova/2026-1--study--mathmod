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

x0 = 0.2
y0 = -0.2

dt = 0.05

println("Параметры задачи:")
println("  X₀ = $x0")
println("  Y₀ = $y0")
println("  Шаг = $dt")

# интервал времени моделирования
t = (0, 55)

println("  Интервал времени моделирования = $t")

# ==========================================================
# 1 МОДЕЛЬ - Колебания гармонического осциллятора без затуханий и без действий внешней силы
# ==========================================================

function model1!(du, u, p, t)
    du[1] = u[2]            
    du[2] = -1.2 * u[1]
end

# Создаём директорию для сохранения графиков
mkpath("plots")

u0 = [x0, y0]

# создаём задачу для решения системы ОДУ
prob1 = ODEProblem(model1!, u0, t)

# численно решаем систему
sol1 = solve(prob1, saveat=dt)

# Извлекаем данные из решения
t1 = sol1.t
x1 = sol1[1, :]  # первая переменная (x)
dx1 = sol1[2, :]  # вторая переменная (dx/dt)

# строим график x(t)
p1_x = plot(t1, x1,
    label = "x(t)",
    xlabel = "t",
    ylabel = "x(t)",
    title = "Модель 1: Колебания без затухания",
    lw = 2)

# строим фазовый портрет (x vs dx/dt)
p1_phase = plot(x1, dx1,
    label = "Фазовая траектория",
    xlabel = "x",
    ylabel = "dx/dt",
    title = "Модель 1: Фазовый портрет",
    lw = 2)

# Объединяем графики
p1 = plot(p1_x, p1_phase, layout=(1,2), size=(1000, 400))

# ==========================================================
# 2 МОДЕЛЬ — Колебания гармонического осциллятора c затуханием и без действий внешней силы
# ==========================================================

function model2!(du, u, p, t)
    du[1] = u[2]                  
    du[2] = -4.3 * u[1] - 2.0 * u[2]
end

# создаём задачу
prob2 = ODEProblem(model2!, u0, t)

# решаем систему
sol2 = solve(prob2, saveat=dt/10)

# Извлекаем данные из решения
t2 = sol2.t
x2 = sol2[1, :]  # первая переменная (x)
dx2 = sol2[2, :]  # вторая переменная (dx/dt)

# строим график x(t)
p2_x = plot(t2, x2,
    label = "x(t)",
    xlabel = "t",
    ylabel = "x(t)",
    title = "Модель 2: Колебания с затуханием",
    lw = 2)

# строим фазовый портрет
p2_phase = plot(x2, dx2,
    label = "Фазовая траектория",
    xlabel = "x",
    ylabel = "dx/dt",
    title = "Модель 2: Фазовый портрет",
    lw = 2)

# Объединяем графики
p2 = plot(p2_x, p2_phase, layout=(1,2), size=(1000, 400))

# ==========================================================
# 3 МОДЕЛЬ — Колебания гармонического осциллятора c затуханием и под действием внешней силы
# ==========================================================

function model3!(du, u, p, t)
    du[1] = u[2]                                    
    du[2] = -7.5 * u[1] - 7.4 * u[2] + 2.2 * cos(0.6 * t)
end

# создаём задачу
prob3 = ODEProblem(model3!, u0, t)

# решаем систему
sol3 = solve(prob3, saveat=dt/20)

# Извлекаем данные из решения
t3 = sol3.t
x3 = sol3[1, :]  # первая переменная (x)
dx3 = sol3[2, :]  # вторая переменная (dx/dt)

# строим график x(t)
p3_x = plot(t3, x3,
    label = "x(t)",
    xlabel = "t",
    ylabel = "x(t)",
    title = "Модель 3: С затуханием и внешней силой",
    lw = 2)

# строим фазовый портрет
p3_phase = plot(x3, dx3,
    label = "Фазовая траектория",
    xlabel = "x",
    ylabel = "dx/dt",
    title = "Модель 3: Фазовый портрет",
    lw = 2)

# Объединяем графики
p3 = plot(p3_x, p3_phase, layout=(1,2), size=(1000, 400))

# ==========================================================
# ДОПОЛНИТЕЛЬНО: Установившийся режим для модели 3
# ==========================================================

# Находим индекс для последних 20 секунд (от 35 до 55)
t_values = sol3.t
idx_start = findfirst(t_values .>= 35.0)

# Инициализируем переменные
p3_steady = nothing
t_steady = nothing
x_steady = nothing
dx_steady = nothing

if idx_start !== nothing && idx_start <= length(t_values)
    # Создаем данные для установившегося режима
    t_steady = sol3.t[idx_start:end]
    x_steady = sol3[idx_start:end, 1]
    dx_steady = sol3[idx_start:end, 2]
    
    # Проверяем, что данные не пустые
    if !isempty(x_steady) && !isempty(dx_steady) && length(x_steady) > 1
        # Фазовый портрет установившегося режима
        p3_steady = plot(x_steady, dx_steady,
            label = "Предельный цикл",
            xlabel = "x",
            ylabel = "dx/dt",
            title = "Модель 3: Установившийся режим",
            lw = 2,
            linewidth = 2)
    else
        println("Предупреждение: Данные установившегося режима пусты или недостаточны")
        p3_steady = plot(title="Установившийся режим: данные отсутствуют")
    end
else
    println("Предупреждение: Не найдены значения времени >= 35.0")
    p3_steady = plot(title="Установившийся режим не найден")
end

# ==========================================================
# ОТОБРАЖЕНИЕ ВСЕХ ГРАФИКОВ
# ==========================================================

# Отображаем все графики вместе (x(t) для всех трех моделей)
p_all_x = plot(t1, x1, label="Модель 1 (без затухания)", lw=2)
plot!(p_all_x, t2, x2, label="Модель 2 (с затуханием)", lw=2)
plot!(p_all_x, t3, x3, label="Модель 3 (с внешней силой)", lw=2)
xlabel!(p_all_x, "t")
ylabel!(p_all_x, "x(t)")
title!(p_all_x, "Сравнение решений x(t) для всех моделей")

# Фазовые портреты всех моделей
p_all_phase = plot(x1, dx1, label="Модель 1 (без затухания)", lw=2)
plot!(p_all_phase, x2, dx2, label="Модель 2 (с затуханием)", lw=2)
plot!(p_all_phase, x3, dx3, label="Модель 3 (с внешней силой)", lw=2)
xlabel!(p_all_phase, "x")
ylabel!(p_all_phase, "dx/dt")
title!(p_all_phase, "Сравнение фазовых портретов")

# Отображаем все графики вместе (три модели в ряд)
println("\nОтображение графиков...")
display(plot(p1, p2, p3, layout=(1,3), size=(1500, 500)))

# ==========================================================
# СОХРАНЕНИЕ ГРАФИКОВ
# ==========================================================

println("\n" * "="^50)
println("СОХРАНЕНИЕ ГРАФИКОВ")
println("="^50)

# Сохраняем графики для каждой модели
try
    savefig(p1, "plots/case1.png")
    println("  Сохранён: plots/case1.png")
catch e
    println("  Ошибка при сохранении case1.png: $e")
end

try
    savefig(p2, "plots/case2.png")
    println("  Сохранён: plots/case2.png")
catch e
    println("  Ошибка при сохранении case2.png: $e")
end

try
    savefig(p3, "plots/case3.png")
    println("  Сохранён: plots/case3.png")
catch e
    println("  Ошибка при сохранении case3.png: $e")
end

# Сохраняем сравнительные графики
try
    savefig(p_all_x, "plots/comparison_x.png")
    println("  Сохранён: plots/comparison_x.png")
catch e
    println("  Ошибка при сохранении comparison_x.png: $e")
end

try
    savefig(p_all_phase, "plots/comparison_phase.png")
    println("  Сохранён: plots/comparison_phase.png")
catch e
    println("  Ошибка при сохранении comparison_phase.png: $e")
end

# Сохраняем установившийся режим, если он существует
if p3_steady !== nothing
    try
        savefig(p3_steady, "plots/case3_steady.png")
        println("  Сохранён: plots/case3_steady.png")
    catch e
        println("  Ошибка при сохранении case3_steady.png: $e")
    end
end

println("\nСохранение графиков завершено")

# ==========================================================
# АНАЛИЗ РЕЗУЛЬТАТОВ
# ==========================================================

println("\n" * "="^50)
println("РЕЗУЛЬТАТЫ МОДЕЛИРОВАНИЯ")
println("="^50)

# Вычисляем параметры для каждой модели
ω0_1 = sqrt(1.2)
γ_1 = 0.0

ω0_2 = sqrt(4.3)
γ_2 = 1.0

ω0_3 = sqrt(7.5)
γ_3 = 3.7

println("\nМодель 1: Без затухания")
println("  ω₀ = √1.2 = $(round(ω0_1, digits=4)) рад/с")
println("  γ = $γ_1")
println("  Характер: незатухающие гармонические колебания")
println("  Фазовая траектория: замкнутая кривая (эллипс)")

println("\nМодель 2: С затуханием")
println("  ω₀ = √4.3 = $(round(ω0_2, digits=4)) рад/с")
println("  γ = $γ_2")
println("  Отношение γ/ω₀ = $(round(γ_2/ω0_2, digits=4))")
if γ_2 < ω0_2
    println("  Характер: затухающие колебания (недозатухание)")
elseif γ_2 == ω0_2
    println("  Характер: критическое затухание")
else
    println("  Характер: апериодическое затухание")
end
println("  Фазовая траектория: спираль, стягивающаяся к началу координат")

println("\nМодель 3: С затуханием и внешней силой")
println("  ω₀ = √7.5 = $(round(ω0_3, digits=4)) рад/с")
println("  γ = $γ_3")
println("  Отношение γ/ω₀ = $(round(γ_3/ω0_3, digits=4))")
println("  Частота внешней силы ω = 0.6 рад/с")
println("  Амплитуда внешней силы F₀ = 2.2")
if γ_3 < ω0_3
    println("  Характер: затухающие колебания с выходом на предельный цикл")
else
    println("  Характер: апериодическое затухание собственных колебаний,")
    println("            затем установившиеся вынужденные колебания с частотой ω = 0.6 рад/с")
end
println("  Фазовая траектория: после переходного процесса выходит на предельный цикл")

# Дополнительный анализ для модели 3 (с проверкой на пустые массивы)
println("\n" * "-"^50)
println("АНАЛИЗ УСТАНОВИВШЕГОСЯ РЕЖИМА МОДЕЛИ 3")
println("-"^50)

if idx_start !== nothing && idx_start <= length(t_values) && 
   x_steady !== nothing && !isempty(x_steady) && length(x_steady) > 1
    
    println("  Интервал анализа: от $(round(t_steady[1], digits=2)) до $(round(t_steady[end], digits=2)) секунд")
    println("  Количество точек: $(length(x_steady))")
    
    # Амплитуда установившихся колебаний
    try
        amp_steady = (maximum(x_steady) - minimum(x_steady)) / 2
        println("  Амплитуда колебаний: $(round(amp_steady, digits=4))")
    catch e
        println("  Не удалось вычислить амплитуду: $e")
    end
    
    # Частота колебаний
    try
        # Находим пересечения нуля
        sign_changes = findall(diff(sign.(x_steady)) .!= 0)
        if !isempty(sign_changes) && length(sign_changes) >= 2
            periods = length(sign_changes) / 2
            time_span = t_steady[end] - t_steady[1]
            if time_span > 0
                freq_steady = periods / time_span
                println("  Частота колебаний: $(round(freq_steady, digits=4)) рад/с")
                println("  Период колебаний: $(round(2π/freq_steady, digits=4)) с")
            else
                println("  Недостаточно данных для определения частоты (временной интервал = 0)")
            end
        else
            println("  Недостаточно пересечений нуля для определения частоты")
        end
    catch e
        println("  Не удалось определить частоту: $e")
    end
    
    # Максимальное отклонение
    try
        max_x = maximum(abs.(x_steady))
        println("  Максимальное отклонение: $(round(max_x, digits=4))")
    catch e
        println("  Не удалось вычислить максимальное отклонение: $e")
    end
    
else
    if idx_start === nothing
        println("  Установившийся режим не достигнут (время < 35 секунд)")
    elseif x_steady === nothing || isempty(x_steady)
        println("  Данные установившегося режима отсутствуют")
    elseif length(x_steady) <= 1
        println("  Недостаточно данных для анализа (всего $(length(x_steady)) точек)")
    else
        println("  Неизвестная ошибка при анализе установившегося режима")
    end
end

println("\n" * "="^50)
println("ПРОГРАММА УСПЕШНО ЗАВЕРШЕНА")
println("="^50)
