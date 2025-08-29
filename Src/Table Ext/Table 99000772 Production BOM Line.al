tableextension 81185 "Prod Bom Lines Ext" extends "Production BOM Line"
{
    fields
    {
        field(81180; "Principal Input"; Boolean)
        {
            Caption = 'Principal Input';
            DataClassification = ToBeClassified;
            Description = 'ProdOrderChangeNote';
            //Editable = false;
        }
    }
}
