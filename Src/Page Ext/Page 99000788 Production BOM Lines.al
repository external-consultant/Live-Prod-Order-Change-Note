pageextension 81188 ProdBomLine81188_Ext extends "Production BOM Lines"
{
    layout
    {
        addafter(Description)
        {
            //T12113-ABA-NS
            field("Principal Input"; Rec."Principal Input")
            {
                ApplicationArea = All;
                Caption = 'Principal Input';
            }
            //T12113-ABA-NE
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}