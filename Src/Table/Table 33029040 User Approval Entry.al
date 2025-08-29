// Table 33029040 "Adv_User Approval Entry"
// {
//     // --------------------------------------------------------------------------------------------------
//     // Intech Systems Pvt. Ltd.
//     // --------------------------------------------------------------------------------------------------
//     // No.                    Date        Author
//     // --------------------------------------------------------------------------------------------------
//     // I-I046-300031-01       18/06/16    Chintan Panchal
//     //                        Purchase Indent Approval Functionality
//     //                        Created New Page
//     // --------------------------------------------------------------------------------------------------


//     fields
//     {
//         field(1; Type; Code[50])
//         {
//             Description = 'PK';
//             Editable = false;
//             NotBlank = true;
//         }
//         field(2; "Entry No."; Integer)
//         {
//             Description = 'PK';
//             Editable = false;
//         }
//         field(21; "Document Type"; Option)
//         {
//             Caption = 'Document Type';
//             Editable = false;
//             OptionCaption = 'Purchase Indent,Purchase Request';
//             OptionMembers = "Purchase Indent","Purchase Request";
//         }
//         field(22; "Document No."; Code[20])
//         {
//             Editable = false;
//         }
//         field(24; "Proposal Raised By"; Code[50])
//         {
//         }
//         field(25; "Proposal Raised Date"; DateTime)
//         {
//         }
//         field(26; "Shortcut Dimension 1 Code"; Code[20])
//         {
//             CaptionClass = '1,2,1';
//             Caption = 'Shortcut Dimension 1 Code';
//             TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
//         }
//         field(27; "Shortcut Dimension 2 Code"; Code[20])
//         {
//             CaptionClass = '1,2,2';
//             Caption = 'Shortcut Dimension 2 Code';
//             TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
//         }
//         field(43; "Approver ID"; Code[50])
//         {
//             Editable = false;
//             TableRelation = "User Setup";

//             trigger OnLookup()
//             var
//                 UserMgt: Codeunit "User Management";
//             begin
//             end;
//         }
//         field(45; Status; Option)
//         {
//             Caption = 'Status';
//             Editable = false;
//             OptionCaption = 'Created,Open,Cancelled,Rejected,Approved';
//             OptionMembers = Created,Open,Cancelled,Rejected,Approved;
//         }
//         field(46; Remarks; Text[250])
//         {
//         }
//         field(47; Select; Boolean)
//         {
//         }
//         field(100; "Requester ID"; Code[50])
//         {
//             Editable = false;
//             TableRelation = "User Setup";

//             trigger OnLookup()
//             var
//                 UserMgt: Codeunit "User Management";
//             begin
//             end;
//         }
//         field(101; "Approval Request Send On"; DateTime)
//         {
//             Editable = false;
//         }
//         field(102; "Approver Response Receive On"; DateTime)
//         {
//             Editable = false;
//         }
//         field(103; "Approval level"; Integer)
//         {
//             Editable = false;
//         }
//         field(104; "Same Level Update"; Boolean)
//         {
//             DataClassification = ToBeClassified;
//             Editable = false;
//         }
//         field(105; "Raw Material Type"; Option)
//         {
//             DataClassification = ToBeClassified;
//             Description = 'T02004';
//             Editable = false;
//             OptionCaption = 'Update LP,Update Customer SP';
//             OptionMembers = "Update LP","Update Customer SP";
//         }
//         field(106; "Prod. Order Status"; Option)
//         {
//             DataClassification = ToBeClassified;
//             Description = 'ProdOrderChangeNote';
//             OptionCaption = ' ,Planned,Firm Planned,Released';
//             OptionMembers = " ",Planned,"Firm Planned",Released;
//         }
//         field(107; "Prod. Order No."; Code[20])
//         {
//             DataClassification = ToBeClassified;
//             Description = 'ProdOrderChangeNote';
//         }
//         field(108; "Prod. Order Line No."; Integer)
//         {
//             BlankNumbers = BlankZero;
//             DataClassification = ToBeClassified;
//             Description = 'ProdOrderChangeNote';
//         }
//         field(109; "Requester Sent Date"; Date)
//         {
//             DataClassification = ToBeClassified;
//             Description = 'ProdOrderChangeNote';
//         }
//         field(110; "Prod. Order Change Note No."; Code[20])
//         {
//             DataClassification = ToBeClassified;
//             Description = 'ProdOrderChangeNote';
//         }
//         field(150; "Rejection Comment"; Text[250])
//         {
//             DataClassification = ToBeClassified;
//             Editable = false;
//         }
//         field(201; "Entry Substituted"; Boolean)
//         {
//             DataClassification = ToBeClassified;
//             Editable = false;
//         }
//         field(202; "Transaction Type"; Option)
//         {
//             DataClassification = ToBeClassified;
//             Description = 'T13825';
//             OptionCaption = 'Sale,Purchase';
//             OptionMembers = Sale,Purchase;
//         }
//     }

//     keys
//     {
//         key(Key1; Type, "Entry No.")
//         {
//             Clustered = true;
//         }
//     }

//     fieldgroups
//     {
//     }
// }

