TableExtension 81180 User_Setup_50022 extends "User Setup"
{
    fields
    {
        //T12149-NS
        field(53013; "Allow Consumption Posting"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'A012_A-1000147-01';
        }
        field(53017; "Allow Prod Ord. Change Approve"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'ProdOrderChangeNote';
        }
        field(53018; "Allow Prod Ord. Change Post"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'ProdOrderChangeNote';
        }
        field(53019; "Allow to Mod Prod Order Comp"; Boolean)
        {
            Caption = 'Allow to Modify Production Order Component';
            DataClassification = ToBeClassified;
            Description = 'ProdOrderChangeNote';
        }
        //T12149-NE

    }
}

