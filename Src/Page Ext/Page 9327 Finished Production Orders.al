PageExtension 81182 Finished_Prod_Orders_50243 extends "Finished Production Orders"
{
    layout
    {

        addafter("Bin Code")
        {
            //T12149-NS
            field("Latest PCN No."; Rec."Latest PCN No.")
            {
                ApplicationArea = All;
            }
            field("Total No. of PCN Posted"; Rec."Total No. of PCN Posted")
            {
                ApplicationArea = All;
                Editable = false;
            }
            //T12149-NE
        }
    }
    actions
    {

        addafter("Prod. Order - Detail Calc.")
        {//T12149-NS
            action("Total No. of PCN Posted View")
            {
                Caption = 'Total No. of PCN Posted';
                Image = List;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteHeader_lRec: Record "Prod. Order Change Note Header";
                begin
                    //T12712-NS
                    ProdOrderChangeNoteHeader_lRec.Reset;
                    ProdOrderChangeNoteHeader_lRec.SetRange("Prod. Order No.", Rec."No.");
                    Page.RunModal(Page::"Posted Prod. Order Change List", ProdOrderChangeNoteHeader_lRec);
                    //T12712-NE
                end;
            }
            //T12149-NE
        }
    }

    var
        [InDataSet]
        ReOpenProdOrderVisible_gBln: Boolean; //T12149-N
        UserSetup_gRec: Record "User Setup"; //T12149-N
}

