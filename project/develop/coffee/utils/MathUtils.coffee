class MathUtils

    @lerp : (ratio, start, end) =>

        start + (end - start) * ratio

    @norm : (val, min, max) =>

        (val - min) / (max - min)

    @map : (val, min1, max1, min2, max2) =>

        @lerp @norm(val, min1, max1), min2, max2
