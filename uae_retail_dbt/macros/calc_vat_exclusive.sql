{% macro calc_vat_exclusive(gross_amount_column, tax_rate_column) %}
    
    -- Calculates the base revenue by removing the UAE VAT component
    -- Formula: Gross Amount / (1 + Tax Rate)
    cast(( {{ gross_amount_column }} / (1 + {{ tax_rate_column }}) ) as decimal(10,2))

{% endmacro %}