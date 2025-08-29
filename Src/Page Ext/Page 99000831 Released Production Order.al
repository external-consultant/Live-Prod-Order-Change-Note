PageExtension 81185 Released_Prod_Order_50261 extends "Released Production Order"
{
    layout
    {
        addafter("Last Date Modified")
        {   //T12149-NS
            field("Latest PCN No."; Rec."Latest PCN No.")
            {
                ApplicationArea = All;
            }
            field("Total No. of PCN Posted"; Rec."Total No. of PCN Posted")
            {
                ApplicationArea = All;
                Editable = false;
            }
             field("No. of Batches"; Rec."No. of Batches")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the No. of Batches field.', Comment = '%';
            }
            //T12149-NE
        }
    }
    actions
    {
        addafter("Registered Invt. Movement Lines")
        {//T12149-NS
            action("Posted Production Change Notes")
            {
                ApplicationArea = All;
                Caption = 'Posted Production Change Notes';
                Image = History;
                RunObject = Page "Posted Prod. Order Change List";
                RunPageLink = "Prod. Order No." = field("No.");
                RunPageView = sorting("No.");
            }
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
                    ProdOrderChangeNoteHeader_lRec.Reset;
                    ProdOrderChangeNoteHeader_lRec.SetRange("Prod. Order No.", Rec."No.");
                    Page.RunModal(Page::"Posted Prod. Order Change List", ProdOrderChangeNoteHeader_lRec);
                end;
            }
            //T12149-NE
        }
    }
}

