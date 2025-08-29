Page 81191 "Prod. Order Components Archive"
{
    // -----------------------------------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // -----------------------------------------------------------------------------------------------------------------------------
    // ID                        Date            Author
    // -----------------------------------------------------------------------------------------------------------------------------
    // I-C0059-1005713-01   10/10/11        KSP
    //                      Added field "Description 2"
    // I-C0059-1400410-01        08/08/14     Chintan Panchal
    //                           C0059-NAV ENHANCEMENTS upgrade to NAV 2013 R2
    // I-C0011-1001330-02  24/07/12     RaviShah
    //                     Subcontracting -> Added Following Field in Table:
    //                     Available in Bulk at SubconLoc
    // I-C0011-1400409-01  07/08/14     Chintan Panchal
    //                     C0011 - SUBCONTRACTING PLUS Upgrade to NAV 2013 R2
    // SubConChngV2        09/08/16     Nilesh Gajjar
    //                     Subcorntracting  Issue
    //                     Added code to prevent deletaion of component if Subcon is created
    // -----------------------------------------------------------------------------------------------------------------------------

    AutoSplitKey = true;
    Caption = 'Prod. Order Components Archive';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Prod. Order Component Archive";
    Description = 'T12149';
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Due Date-Time"; Rec."Due Date-Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                }
                field("Scrap %"; Rec."Scrap %")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Calculation Formula"; Rec."Calculation Formula")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Length; Rec.Length)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Depth; Rec.Depth)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Quantity per"; Rec."Quantity per")
                {
                    ApplicationArea = All;
                }
                field("Reserved Quantity"; Rec."Reserved Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Flushing Method"; Rec."Flushing Method")
                {
                    ApplicationArea = All;
                }
                field("Expected Quantity"; Rec."Expected Quantity")
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                field("Qty Send at SubCon Location"; Rec."Qty Send at SubCon Location")
                {
                    ApplicationArea = All;
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Routing Link Code"; Rec."Routing Link Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Position 2"; Rec."Position 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Position 3"; Rec."Position 3")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Lead-Time Offset"; Rec."Lead-Time Offset")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Qty. Picked"; Rec."Qty. Picked")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Qty. Picked (Base)"; Rec."Qty. Picked (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Available in Bulk at SubconLoc"; Rec."Available in Bulk at SubconLoc")
                {
                    ApplicationArea = All;
                }
                field("Substitution Available"; Rec."Substitution Available")
                {
                    ApplicationArea = All;
                }
                field("Act. Consumption (Qty)"; Rec."Act. Consumption (Qty)")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    var
        ReserveProdOrderComp: Codeunit "Prod. Order Comp.-Reserve";
    begin
    end;

    trigger OnOpenPage()
    var
        ManufacturingSetup_lRec: Record "Manufacturing Setup";
    begin
    end;
}

