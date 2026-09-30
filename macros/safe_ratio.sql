{# Division that returns null instead of failing or returning infinity when the denominator is 0. #}
{% macro safe_ratio(numerator, denominator, precision=4) -%}
    round(cast({{ numerator }} as double) / nullif({{ denominator }}, 0), {{ precision }})
{%- endmacro %}
