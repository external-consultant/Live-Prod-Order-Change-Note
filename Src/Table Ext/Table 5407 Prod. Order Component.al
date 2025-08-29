tableextension 81184 "Prod Order Comp Ext" extends "Prod. Order Component"
{
    fields
    {
        field(50139; "Principal Input"; Boolean)
        {
            Caption = 'Principal Input';
            DataClassification = ToBeClassified;
            Description = 'ProdOrderChangeNote';
            Editable = false;
        }
        field(50361; Recovery; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'T10146';
            Editable = false;
        }
        field(50362; "FG Recovery"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'T10146';
            Editable = false;
        }
    }
}
