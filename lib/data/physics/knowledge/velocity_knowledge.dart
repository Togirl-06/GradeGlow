/// Complete digital textbook chapter for Velocity (kinematics).
String velocityCompleteKnowledge() => r'''
# Chapter 5: Velocity

*Kinematics · Undergraduate Core · Virtual University Physics*

---

## 5.1 Introduction

Velocity is one of the most important concepts in physics because **everything that moves has velocity**. It is the foundation for mechanics, engineering, aerospace, robotics, and almost every physics field.

Velocity is a **vector quantity** that describes the rate at which an object's position changes with respect to time. Unlike speed, velocity includes both magnitude and direction, making it dependent on the chosen reference frame.

A student who masters this chapter can define every term, derive the governing relations, solve quantitative problems, interpret graphs, connect the idea to engineering practice, and verify predictions in the virtual laboratory — without needing an external textbook.

---

## 5.2 Historical Background

Galileo's experiments on inclined planes showed that motion could be described mathematically without Aristotelian ideas about natural and violent motion. Newton's *Principia* unified terrestrial and celestial mechanics, making velocity a central variable in **v = dx/dt** and in the laws of motion.

Today, velocity measurements drive GPS navigation, rocket guidance, medical ultrasound, and autonomous vehicles.

---

## 5.3 Definition of Velocity

**Velocity is the rate of change of position with respect to time in a specific direction.**

In plain language: velocity tells you **how fast** something moves **and which direction** it moves.

$$v = \frac{\Delta x}{\Delta t}$$

Where:

- **$v$** = velocity
- **$\Delta x$** = displacement (change in position)
- **$\Delta t$** = change in time

**Worked example:** A car travels 100 m east in 20 s.

$$v = \frac{100}{20} = 5 \text{ m/s east}$$

---

## 5.4 Velocity vs Speed

| Speed | Velocity |
| --- | --- |
| Scalar quantity | Vector quantity |
| No direction | Has direction |
| Always positive (magnitude) | Can be positive or negative along an axis |
| Distance / time | Displacement / time |

- Speed only: *60 km/h*
- Velocity: *60 km/h north*

---

## 5.5 Scalar vs Vector

**Scalars** have magnitude only: speed, mass, temperature, time.

**Vectors** have magnitude **and** direction: velocity, acceleration, force, momentum.

*20 m/s* alone is incomplete. Correct: **20 m/s west**.

---

## 5.6 Units of Velocity

**SI unit:** meters per second (**m/s**)

Common alternatives:

- km/h (road vehicles)
- mph (US road speed)
- ft/s (some engineering contexts)

---

## 5.7 Converting Velocity Units

**km/h → m/s:** multiply by $\frac{1000}{3600}$

Example: $72 \times \frac{1000}{3600} = 20$ m/s

**m/s → km/h:** multiply by **3.6**

Example: $10 \times 3.6 = 36$ km/h

---

## 5.8 Average Velocity

$$v_{\text{avg}} = \frac{\text{total displacement}}{\text{total time}}$$

**Example:** 200 m east, then 50 m west → displacement = 150 m east in 50 s.

$$v = \frac{150}{50} = 3 \text{ m/s east}$$

---

## 5.9 Instantaneous Velocity

**Instantaneous velocity** is the velocity at one exact moment (speedometer reading, rocket speed at ignition).

$$v = \frac{dx}{dt}$$

Velocity is the **derivative of position** with respect to time.

---

## 5.10 Positive and Negative Velocity

Choose an axis: right = positive, left = negative.

- Moving right: $+20$ m/s
- Moving left: $-20$ m/s

Negative does **not** mean slower — it means **opposite direction**.

---

## 5.11 Velocity–Time Graphs

- **Horizontal line** → constant velocity (zero acceleration)
- **Sloped line** → velocity changing → **acceleration**

---

## 5.12 Position–Time Graphs

Slope of position vs time equals **velocity**.

- Steep slope → high velocity
- Flat line → no motion

---

## 5.13 Acceleration and Velocity

$$a = \frac{\Delta v}{\Delta t}$$

**Example:** $0$ m/s to $20$ m/s in $5$ s → $a = \frac{20}{5} = 4$ m/s²

---

### Constant Velocity

Same speed **and** same direction → acceleration $= 0$ (e.g. cruise control at 100 km/h east).

---

### Changing Velocity

Velocity changes when:

1. **Speed changes** (accelerating car)
2. **Direction changes** (car turning a corner — even at constant speed)

---

## 5.14 Key Velocity Equations

**Basic:** $v = \frac{d}{t}$

**Final velocity:** $v_f = v_i + at$

**Displacement:** $\Delta x = v_i t + \frac{1}{2}at^2$

**Without time:** $v_f^2 = v_i^2 + 2a\Delta x$

---

## 5.15 Projectile, Circular, and Relative Velocity

### Projectile Velocity

- **Horizontal:** $v_x$ — constant (no air drag)
- **Vertical:** $v_y$ — changes due to gravity

Total velocity is the **vector sum** of components.

---

### Circular Motion Velocity

**Tangential speed along a circle:**

$$v = \frac{2\pi r}{T}$$

$r$ = radius, $T$ = period (time for one revolution).

---

### Angular Velocity

$$\omega = \frac{\Delta\theta}{\Delta t} \quad \text{(rad/s)}$$

Used in motors, wheels, turbines, spacecraft attitude control.

---

### Relative Velocity

Velocity depends on the observer.

Car A: 80 km/h east; Car B: 50 km/h east → relative velocity of A from B = **30 km/h**.

---

## 5.16 Advanced Concepts — Beyond the Classroom

### Terminal Velocity

When gravity = air resistance, falling speed becomes **constant** (skydivers, raindrops).

---

### Escape Velocity

Minimum speed to escape a planet's gravity without further propulsion.

Earth: **≈ 11.2 km/s** — critical for rockets and deep-space missions.

---

**Relativistic note:** At speeds approaching the speed of light, velocity addition differs from Galilean relativity. No massive object reaches $c$.

---

## 5.17 Real-World Applications

- **Aerospace:** launch speed, orbital velocity, escape velocity
- **Robotics:** end-effector and joint speeds
- **Automotive:** acceleration, braking, crash analysis
- **Medicine:** blood flow velocity in diagnostics

---

## 5.18 Virtual Laboratory & Simulation

**Lab 1 — Measure velocity:** camera + distance sensor + timer; compute $v = \Delta x / \Delta t$.

**Lab 2 — Rocket design:** adjust fuel, mass, thrust; measure velocity, acceleration, apogee.

**Lab 3 — Crash analysis:** initial velocity, final velocity, impact speed from momentum data.

---

## 5.19 Practice Problems & Exam Questions

**Beginner:** A runner travels 400 m in 50 s. What is average velocity?

**Intermediate:** A rocket goes from 100 m/s to 900 m/s in 20 s. Find acceleration.

**Advanced:** A spacecraft turns at constant speed. Why does velocity change?

**Expert:** Design an orbital trajectory using velocity vectors and energy.

---

## 5.20 Summary

- Velocity is a **vector**; speed is its scalar magnitude.
- Average velocity uses **displacement**, not total distance.
- Graph slopes and kinematic equations link position, velocity, and acceleration.
- Applications span aerospace, robotics, medicine, and automotive safety.
- Verify every prediction in the **3D Simulation & Lab**.

---

## 5.21 Mastery Checklist

A student masters velocity when they can:

- Define velocity as a vector
- Calculate average and instantaneous velocity
- Convert between m/s, km/h, and mph
- Read velocity and position graphs
- Relate velocity to acceleration
- Solve 1D and projectile component problems
- Explain relative, terminal, and escape velocity
- Apply velocity in engineering contexts

This is the level expected before **acceleration, forces, and Newton's laws**.
''';
