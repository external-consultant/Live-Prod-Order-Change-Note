Page 81186 "Doc. Prod. Order Change App."
{
    ApplicationArea = All;
    Caption = 'Document Prod. Order Change Note Approval Entry';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Adv_User Approval Entry";
    SourceTableView = sorting("Approval Source", "Entry No.")
                      where("Approval Source" = filter("Production Change Note"));
    UsageCategory = Lists;
    Description = 'T12149';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = All;
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = All;
                }
                field("Requester ID"; Rec."Requester ID")
                {
                    ApplicationArea = All;
                }
                field("Requester Sent Date"; Rec."Requester Sent Date")
                {
                    ApplicationArea = All;
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
            }
        }
    }

    actions
    {
        area(processing)
        {
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
        }
    }
}

