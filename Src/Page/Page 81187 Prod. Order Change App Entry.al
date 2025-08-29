Page 81187 "Prod. Order Change App. Entry"
{
    ApplicationArea = All;
    Caption = 'Prod. Order Change Approval Entry';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Adv_User Approval Entry";
    SourceTableView = sorting("Approval Source", "Entry No.")
                      where("Line Status" = filter(Open),
                            "Approval Source" = filter("Production Change Note"));
    UsageCategory = Tasks;
    Description = 'T12149';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Select; Rec.Select)
                {
                    ApplicationArea = All;
                }
                field("Approval Source"; Rec."Approval Source")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Requester ID"; Rec."Requester ID")
                {
                    ApplicationArea = All;
                }
                field("Requester Sent Date"; Rec."Requester Sent Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approver ID"; Rec."Approver ID")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec."Line Status")
                {
                    ApplicationArea = All;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                }
                field("Approval Request Send On"; Rec."Approval Request Send On")
                {
                    ApplicationArea = All;
                }
                field("Approver Response Receive On"; Rec."Approver Response Receive On")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order Change Note No."; Rec."Prod. Order Change Note No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Approve)
            {
                ApplicationArea = All;
                Caption = '&Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteAppMgmt_lCdu: Codeunit "Prod. Order Change App. Mgmt";
                begin
                    ProdOrderChangeNoteAppMgmt_lCdu.ApproveSelectedEntry_gFnc(Rec, true);
                end;
            }
            action(Reject)
            {
                ApplicationArea = All;
                Caption = '&Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteAppMgmt_lCdu: Codeunit "Prod. Order Change App. Mgmt";
                begin
                    ProdOrderChangeNoteAppMgmt_lCdu.RejectSelectedEntry_gFnc(Rec, true);
                end;
            }
            action(Delegate)
            {
                ApplicationArea = All;
                Caption = 'Delegate';
                Image = Delegate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    ProdOrderChangeNoteAppMgmt_lCdu: Codeunit "Prod. Order Change App. Mgmt";
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    ProdOrderChangeNoteAppMgmt_lCdu.DelegateApprovalRequests_gFnc(Rec);
                end;
            }
            action("Show Prod Order change note Card")
            {
                ApplicationArea = All;
                Caption = 'Show Prod Order change note Card';
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ProdOrderChangeNoteHdr_lRec: Record "Prod. Order Change Note Header";
                    ProdOrderChangeNoteCard_lPge: Page "Prod. Order Change Note Card";
                begin
                    Clear(ProdOrderChangeNoteCard_lPge);
                    ProdOrderChangeNoteHdr_lRec.Reset;
                    ProdOrderChangeNoteHdr_lRec.SetRange("No.", Rec."Prod. Order Change Note No.");
                    ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order Status", Rec."Prod. Order Status");
                    ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order No.", Rec."Prod. Order No.");
                    ProdOrderChangeNoteHdr_lRec.SetRange("Prod. Order Line No.", Rec."Prod. Order Line No.");
                    ProdOrderChangeNoteCard_lPge.SetTableview(ProdOrderChangeNoteHdr_lRec);
                    ProdOrderChangeNoteCard_lPge.Editable(false);
                    ProdOrderChangeNoteCard_lPge.RunModal;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Approver ID", UserId);
        Rec.FilterGroup(0);
    end;
}

