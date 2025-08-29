TableExtension 81181 Manufacturing_Setup_33028963 extends "Manufacturing Setup"
{
    fields
    {
        //T12149-NS
        field(50141; "Check Qty. per Sum equals 1"; Boolean)
        {
            Caption = 'Check Qty. per Sum equals 1';
            DataClassification = ToBeClassified;
            Description = 'ProdOrderChangeNote';
        }
        field(50142; "Match Tot Qty. with Princple"; Boolean)
        {
            Caption = 'Match Total Qty. with Princple Input Qty.';
            DataClassification = ToBeClassified;
            Description = 'ProdOrderChangeNote';
        }

        field(50405; "Item Templete - Con. Neg. Adj."; Code[10])
        {
            Caption = 'Item Journal Templete - Consumption Negative Adjustment';
            DataClassification = ToBeClassified;
            Description = 'CP,ProdOrderChangeNote,T2939';
            TableRelation = "Item Journal Template" where(Type = const(Consumption));
        }
        field(50406; "Enable Production Change Note"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'T2939';
        }
        field(50407; "Item Batch - Con. Neg. Adj."; Code[10])
        {
            Caption = 'Item Journal Batch Name - Consumption Negative Adjustment';
            DataClassification = ToBeClassified;
            Description = 'CP,ProdOrderChangeNote,T2939';
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("Item Templete - Con. Neg. Adj."));
        }
        field(53011; "Prod. Order Change No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'CP,ProdOrderChangeNote,T2939';
            TableRelation = "No. Series";
        }
        //T12149-Ne

        field(53012; "Allow PO Qty Change in PCN"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        [InDataSet]
        IsLocSelectedFromList_gBln: Boolean;
}

